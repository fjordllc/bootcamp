# frozen_string_literal: true

class User < ActiveRecord::Base
  include ActionView::Helpers::AssetUrlHelper

  authenticates_with_sorcery!
  VALID_SORT_COLUMNS = %w(id login_name company_id updated_at created_at report comment asc desc)
  AVATAR_SIZE = "88x88>"

  enum job: {
    student: 0,
    office_worker: 2,
    part_time_worker: 3,
    vacation: 4,
    unemployed: 5
  }, _prefix: true

  enum os: {
    mac: 0,
    linux: 1
  }, _prefix: true

  enum study_place: {
    local: 0,
    remote: 1
  }, _prefix: true

  enum experience: {
    inexperienced: 0,
    html_css: 1,
    other_ruby: 2,
    ruby: 3,
    rails: 4
  }, _prefix: true

  belongs_to :company, required: false
  belongs_to :course
  has_many :learnings
  has_many :borrowings
  has_many :comments,      dependent: :destroy
  has_many :reports,       dependent: :destroy
  has_many :checks,        dependent: :destroy
  has_many :footprints,    dependent: :destroy
  has_many :images,        dependent: :destroy
  has_many :products,      dependent: :destroy
  has_many :questions,     dependent: :destroy
  has_many :announcements, dependent: :destroy
  has_many :reactions,     dependent: :destroy
  has_many :works,         dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :events,        dependent: :destroy
  has_many :participations, dependent: :destroy

  has_many :participate_events,
    through: :participations,
    source: :event

  has_many :send_notifications,
    class_name:  "Notification",
    foreign_key: "sender_id",
    dependent:   :destroy

  has_many :completed_learnings,
    -> { where(status: "complete") },
    class_name: "Learning",
    dependent:  :destroy

  has_many :completed_practices,
    through:   :completed_learnings,
    source:    :practice,
    dependent: :destroy

  has_many :active_learnings,
    -> { where(status: "started") },
    class_name: "Learning",
    dependent:  :destroy

  has_many :active_practices,
    through:   :active_learnings,
    source:    :practice,
    dependent: :destroy

  has_many :books,
    through: :borrowings

  has_one_attached :avatar

  after_update UserCallbacks.new

  validates :email,      presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name,  presence: true
  validates :login_name, presence: true, uniqueness: true
  validates :nda, presence: true
  validates :password, length: { minimum: 4 }, confirmation: true, if: :password_required?
  validates :twitter_account,
    length: { maximum: 15 },
    format: {
      allow_blank: true,
      with: /\A\w+\z/,
      message: "は英文字と_（アンダースコア）のみが使用できます"
    }
  validates :mail_notification, inclusion: { in: [true, false] }

  with_options if: -> { validation_context != :reset_password && validation_context != :retirement } do
    validates :kana_first_name,  presence: true,
    format: {
      with: /\A^[ア-ン゛゜ァ-ォャ-ョー]+\z/,
      message: "はカタカナのみが使用できます"
    }
    validates :kana_last_name,  presence: true,
    format: {
      with: /\A^[ア-ン゛゜ァ-ォャ-ョー]+\z/,
      message: "はカタカナのみが使用できます"
    }
  end

  with_options if: -> { !adviser? && validation_context != :reset_password && validation_context != :retirement } do
    validates :job, presence: true
    validates :os, presence: true
    validates :study_place, presence: true
    validates :experience, presence: true
  end

  scope :in_school, -> { where(graduated_on: nil) }
  scope :graduated, -> { where.not(graduated_on: nil) }
  scope :retired, -> { where.not(retired_on: nil) }
  scope :advisers, -> { where(adviser: true) }
  scope :not_advisers, -> { where(adviser: false) }
  scope :students, -> {
    where(
      admin: false,
      mentor: false,
      adviser: false,
      graduated_on: nil,
      retired_on: nil
    )
  }
  scope :active, -> { where(updated_at: 1.month.ago..Float::INFINITY) }
  scope :inactive, -> {
    where(
      updated_at: Date.new..1.month.ago,
      adviser: false,
      retired_on: nil,
      graduated_on: nil
    )
  }
  scope :year_end_party, -> { where(retired_on: nil) }
  scope :mentor, -> { where(mentor: true) }
  scope :working, -> {
    active.where(
      adviser: false,
      graduated_on: nil,
      retired_on: nil
    ).order(updated_at: :desc)
  }
  scope :admins, -> { where(admin: true) }
  scope :trainee, -> { where(trainee: true) }
  scope :job_seeking, -> { where(job_seeking: true) }
  scope :order_by_counts, -> (order_by, direction) {
    unless order_by.in?(VALID_SORT_COLUMNS) && direction.in?(VALID_SORT_COLUMNS)
      raise ArgumentError, "Invalid argument"
    end

    if order_by.in? ["report", "comment"]
      left_outer_joins(order_by.pluralize.to_sym)
        .group("users.id")
        .order(Arel.sql("count(#{order_by.pluralize}.id) #{direction}, users.created_at"))
    else
      order(order_by.to_sym => direction.to_sym, created_at: :asc)
    end
  }

  def away?
    self.updated_at <= 10.minutes.ago
  end

  def completed_percentage
    completed_practices.size.to_f / course.practices.count.to_f * 100
  end

  def completed_practices_size(category)
    completed_practices.where(category_id: category.id).size
  end

  def completed_percentage_by(category)
    completed_practices_size(category).to_f / category.practices.size.to_f * 100
  end

  def full_name
    "#{last_name} #{first_name}"
  end

  def kana_full_name
    "#{kana_last_name} #{kana_first_name}"
  end

  def active?
    updated_at > 1.month.ago
  end

  def has_checked_product_of?(*practices)
    products.where(practice: practices).any?(&:checked?)
  end

  def practices_with_checked_product
    Practice.where(products: products.checked)
  end

  def total_learning_time
    sql = <<-SQL
SELECT
  SUM(EXTRACT(epoch from learning_times.finished_at - learning_times.started_at) / 60 / 60) AS total
FROM
  learning_times JOIN reports ON learning_times.report_id = reports.id
WHERE
  reports.user_id = :user_id
SQL

    learning_time = LearningTime.find_by_sql([sql, { user_id: id }])
    learning_time.first.total || 0
  end

  def self.users_role(target)
    case target
    when "student"
      self.students
    when "job_seeking"
      self.job_seeking
    when "retired"
      self.retired
    when "graduate"
      self.graduated
    when "adviser"
      self.advisers
    when "mentor"
      self.mentor
    when "inactive"
      self.inactive.order(:updated_at)
    when "year_end_party"
      self.year_end_party
    when "trainee"
      self.trainee
    when "all"
      self.all
    end
  end

  def prefecture_name
    if prefecture_code.nil?
      "未登録"
    else
      pref = JpPrefecture::Prefecture.find prefecture_code
      pref.name
    end
  end

  def elapsed_days
    (Date.current - self.created_at.to_date).to_i
  end

  def customer
    if customer_id?
      Stripe::Customer.retrieve(customer_id)
    end
  end

  def card?
    customer_id?
  end

  alias_method :paid?, :card?

  def card
    customer.sources.data.first
  end

  def student?
    !admin? && !adviser? && !mentor? && !trainee?
  end

  def staff?
    admin? || mentor? || adviser?
  end

  def staff_or_paid?
    staff? || paid?
  end

  def adviser_or_mentor?
    adviser? || mentor?
  end

  def retired?
    retired_on?
  end

  def unread_notifications_count
    @unread_notifications_count ||= notifications.unreads.count
  end

  def unread_notifications_exists?
    unread_notifications_count > 0
  end

  def borrow(book)
    book.update(borrowed: true)
    borrowings.create(book_id: book.id)
  end

  def give_back(book)
    book.update(borrowed: false)
    borrowings.find_by(book_id: book.id).destroy
  end

  def borrowing?(book)
    borrowings.exists?(book_id: book.id)
  end

  def avatar_url
    if avatar.attached?
      avatar.variant(resize: AVATAR_SIZE).service_url
    else
      image_url("/images/users/avatars/default.png")
    end
  end

  def resize_avatar!
    if avatar.attached?
      avatar.variant(resize: AVATAR_SIZE).processed
    end
  end

  def generation
    (created_at.year - 2013) * 4 + (created_at.month + 2) / 3
  end

  def participating?(event)
    participate_events.include?(event)
  end

  private
    def password_required?
      new_record? || password.present?
    end
end
