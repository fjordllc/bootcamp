# frozen_string_literal: true

class User < ActiveRecord::Base
  authenticates_with_sorcery!
  VALID_SORT_COLUMNS = %w(id login_name company_id updated_at report comment asc desc)

  enum job: {
    student: 0,
    office_worker: 2,
    part_time_worker: 3,
    vacation: 4,
    unemployed: 5
  }

  enum os: {
    mac: 0,
    linux: 1
  }

  enum study_place: {
    local: 0,
    remote: 1
  }

  enum experience: {
    inexperienced: 0,
    html_css: 1,
    other_ruby: 2,
    ruby: 3,
    rails: 4
  }

  belongs_to :company
  belongs_to :course
  has_many :learnings
  has_many :comments,      dependent: :destroy
  has_many :reports,       dependent: :destroy
  has_many :checks,        dependent: :destroy
  has_many :footprints,    dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :images,        dependent: :destroy
  has_many :products,      dependent: :destroy
  has_many :questions,     dependent: :destroy
  has_many :announcements, dependent: :destroy

  has_many :send_notifications,
    class_name:  "Notification",
    foreign_key: "sender_id",
    dependent:   :destroy

  has_many :completed_learnings,
    -> { where(status_cd: 1) },
    class_name: "Learning",
    dependent:  :destroy

  has_many :completed_practices,
    through:   :completed_learnings,
    source:    :practice,
    dependent: :destroy

  has_many :active_learnings,
    -> { where(status_cd: 0) },
    class_name: "Learning",
    dependent:  :destroy

  has_many :active_practices,
    through:   :active_learnings,
    source:    :practice,
    dependent: :destroy

  has_one_attached :face
  has_one_attached :avatar

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
  validates :avatar, presence: true, blob: { content_type: :image, size_range: 0..10.megabytes }
  validates :retire_reason, presence: true, length: { minimum: 8 }, on: :retire_reason_presence

  with_options unless: :adviser? do
    validates :description, presence: true
    validates :job, presence: true
    validates :organization, presence: true
    validates :os, presence: true
    validates :study_place, presence: true
    validates :experience, presence: true
    validates :how_did_you_know, presence: true
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
    active.with_attached_face.with_attached_avatar.where(
      adviser: false,
      graduated_on: nil,
      retired_on: nil
    ).order(updated_at: :desc)
  }
  scope :admins, -> { where(admin: true) }
  scope :trainee, -> { where(trainee: true) }
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
  SUM(
    CASE
      WHEN
        EXTRACT(epoch from learning_times.finished_at - learning_times.started_at) < 0
        THEN (EXTRACT(epoch FROM learning_times.finished_at - learning_times.started_at) + (60 * 60 * 24)) / 60 / 60
      ELSE
         EXTRACT(epoch from learning_times.finished_at - learning_times.started_at) / 60 / 60
    END
  ) AS total
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

  def elapsed_days
    (Date.current - self.created_at.to_date).to_i
  end

  private
    def password_required?
      new_record? || password.present?
    end
end
