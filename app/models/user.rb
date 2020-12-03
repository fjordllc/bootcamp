# frozen_string_literal: true

class User < ApplicationRecord
  include ActionView::Helpers::AssetUrlHelper

  authenticates_with_sorcery!
  VALID_SORT_COLUMNS = %w(id login_name company_id updated_at created_at report comment asc desc)
  AVATAR_SIZE = "88x88>"
  RESERVED_LOGIN_NAMES = %w(adviser all graduate inactive job_seeking mentor retired student student_and_trainee trainee year_end_party)

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

  enum experience: {
    inexperienced: 0,
    html_css: 1,
    other_ruby: 2,
    ruby: 3,
    rails: 4
  }, _prefix: true

  enum satisfaction: {
    excellent: 0,
    good: 1,
    average: 2,
    poor: 3,
    very_poor: 4
  }, _prefix: true

  belongs_to :company, optional: true
  belongs_to :course
  has_many :learnings
  has_many :borrowings
  has_many :pages, dependent: :destroy
  has_many :last_updated_pages, class_name: "Page"
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
  has_many :reservations, dependent: :destroy
  has_many :answers,      dependent: :destroy

  has_many :participate_events,
           through: :participations,
           source: :event

  has_many :send_notifications,
           class_name: "Notification",
           foreign_key: "sender_id",
           inverse_of: "sender",
           dependent: :destroy

  has_many :completed_learnings,
           -> { where(status: "complete") },
           class_name: "Learning",
           inverse_of: "user",
           dependent: :destroy

  has_many :completed_practices,
           through: :completed_learnings,
           source: :practice,
           dependent: :destroy

  has_many :active_learnings,
           -> { where(status: "started") },
           class_name: "Learning",
           inverse_of: "user",
           dependent: :destroy

  has_many :active_practices,
           through: :active_learnings,
           source: :practice,
           dependent: :destroy

  has_many :books,
           through: :borrowings

  has_many :last_updated_practices, class_name: "Practice"

  has_many :active_relationships,
           class_name: "Following",
           foreign_key: "follower_id",
           inverse_of: "follower",
           dependent: :destroy

  has_many :following,
           through: :active_relationships,
           source: :followed

  has_many :passive_relationships,
           class_name: "Following",
           foreign_key: "followed_id",
           inverse_of: "followed",
           dependent: :destroy

  has_many :followers,
           through: :passive_relationships,
           source: :follower

  has_one_attached :avatar

  before_create UserCallbacks.new
  after_update UserCallbacks.new

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
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
  validates :github_id, uniqueness: true, allow_nil: true

  validates :login_name, exclusion: { in: RESERVED_LOGIN_NAMES, message: "に使用できない文字列が含まれています" }

  with_options if: -> { %i[create update].include? validation_context } do
    validates :login_name, presence: true, uniqueness: true,
                           format: {
                             with: /\A[a-z\d](?:[a-z\d]|-(?=[a-z\d]))*\z/i,
                             message: "は半角英数字と-（ハイフン）のみが使用できます 先頭と最後にハイフンを使用することはできません ハイフンを連続して使用することはできません"
                           }
  end

  with_options if: -> { validation_context != :reset_password && validation_context != :retirement } do
    validates :name_kana,  presence: true,
                           format: {
                             with: /\A^[ 　ア-ン゛゜ァ-ォャ-ョー]+\z/,
                             message: "はスペースとカタカナのみが使用できます"
                           }
  end

  with_options if: -> { !adviser? && validation_context != :reset_password && validation_context != :retirement } do
    validates :job, presence: true
    validates :os, presence: true
    validates :experience, presence: true
  end

  with_options if: -> { validation_context == :retirement } do
    validates :satisfaction, presence: true
  end

  flag :retire_reasons, [
    :done,
    :necessity,
    :other_school,
    :time,
    :motivation,
    :curriculum,
    :support,
    :environment,
    :cost,
    :job_change
  ]

  scope :in_school, -> { where(graduated_on: nil) }
  scope :graduated, -> { where.not(graduated_on: nil) }
  scope :retired, -> { where.not(retired_on: nil) }
  scope :unretired, -> { where(retired_on: nil) }
  scope :advisers, -> { where(adviser: true) }
  scope :not_advisers, -> { where(adviser: false) }
  scope :students_and_trainees, -> {
    where(
      admin: false,
      mentor: false,
      adviser: false,
      graduated_on: nil,
      retired_on: nil
    )
  }
  scope :students, -> {
    where(
      admin: false,
      mentor: false,
      adviser: false,
      trainee: false,
      retired_on: nil,
      graduated_on: nil
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
  scope :inactive_students_and_trainees, -> {
    where(
      updated_at: Date.new..1.month.ago,
      admin: false,
      mentor: false,
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
  scope :trainees, -> { where(trainee: true) }
  scope :job_seeking, -> { where(job_seeking: true) }
  scope :job_seekers, -> {
    students.where(
      job_seeker: true
    )
  }
  scope :order_by_counts, ->(order_by, direction) {
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
  scope :same_generations, -> (start_date, end_date) {
    where(created_at: start_date..end_date)
      .unretired
      .order(:created_at)
  }

  class << self
    def announcement_receiver(target)
      case target
      when "all"
        User.unretired
      when "students"
        User.admins.or(User.students)
      when "job_seekers"
        User.admins.or(User.job_seekers)
      else
        User.none
      end
    end

    def users_role(target)
      case target
      when "student_and_trainee"
        self.students_and_trainees
      when "graduate"
        self.graduated
      when "adviser"
        self.advisers
      when "inactive"
        self.inactive.order(:updated_at)
      when "trainee"
        self.trainees
      else
        self.send(target)
      end
    end
  end

  def away?
    self.updated_at <= 10.minutes.ago
  end

  def completed_percentage
    completed_practices.where(include_progress: true).size.to_f / course.practices.where(include_progress: true).count * 100
  end

  def completed_practices_size(category)
    Practice
      .joins({ categories: :categories_practices  }, :learnings)
      .distinct(:id)
      .where(
        categories_practices: { category_id: category.id },
        learnings: {
          user_id: id,
          status: "complete"
        }
      )
      .size
  end

  def completed_percentage_by(category)
    completed_practices_size(category).to_f / category.practices.size * 100
  end

  def active?
    updated_at > 1.month.ago
  end

  def checked_product_of?(*practices)
    products.where(practice: practices).any?(&:checked?)
  end

  def practices_with_checked_product
    Practice.where(products: products.checked)
  end

  def total_learning_time
    sql = <<~SQL
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
    return unless customer_id?

    Customer.new.retrieve(customer_id)
  end

  def card?
    customer_id?
  end

  alias paid? card?

  def card
    customer.sources.data.first
  end

  def subscription?
    subscription_id?
  end

  def subscription
    return unless subscription?

    Subscription.new.retrieve(subscription_id)
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

  def graduated?
    graduated_on?
  end

  def student_or_trainee?
    !staff? && !retired? && !graduated?
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
    return unless avatar.attached?

    avatar.variant(resize: AVATAR_SIZE).processed
  end

  def generation
    (created_at.year - 2013) * 4 + (created_at.month + 2) / 3
  end

  def participating?(event)
    participate_events.include?(event)
  end

  def reports_date_and_emotion(term)
    search_term = (Time.zone.today - term.day)..Time.zone.today
    reports = self.reports.where(reported_on: search_term)

    emotions = reports.index_by(&:reported_on)

    dates = search_term.index_with { |_day| nil }

    dates.merge(emotions)
         .to_a
         .map { |set| [report: set[1], date: set[0], emotion: set[1]&.emotion] }
         .flatten
  end

  def daimyo?
    company&.name == "DAIMYO Engineer College"
  end

  def register_github_account(id, account_name)
    self.github_account = account_name
    self.github_id = id
    self.save!
  end

  def depressed?
    three_days_emotions = self.reports.order(reported_on: :desc).limit(3).pluck(:emotion)
    !three_days_emotions.empty? && three_days_emotions.all?("sad")
  end

  def active_practice
    return unless self.active_practices.first

    self.active_practices.first.id
  end

  def follow(other_user)
    following << other_user
  end

  def unfollow(other_user)
    Following.find_by(followed_id: other_user.id).destroy
  end

  def following?(other_user)
    following.include?(other_user)
  end

  def completed_all_practices?(category)
    category.practices.size == completed_practices_size(category)
  end

  private

  def password_required?
    new_record? || password.present?
  end
end
