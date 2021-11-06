# frozen_string_literal: true

class User < ApplicationRecord
  include ActionView::Helpers::AssetUrlHelper
  include Taggable
  include Searchable

  authenticates_with_sorcery!
  VALID_SORT_COLUMNS = %w[id login_name company_id updated_at created_at report comment asc desc].freeze
  AVATAR_SIZE = '88x88>'
  RESERVED_LOGIN_NAMES = %w[adviser all graduate inactive job_seeking mentor retired student student_and_trainee trainee year_end_party].freeze
  MAX_PERCENTAGE = 100
  DEPRESSED_SIZE = 2

  enum job: {
    student: 0,
    office_worker: 2,
    part_time_worker: 3,
    vacation: 4,
    unemployed: 5
  }, _prefix: true

  enum os: {
    mac: 0,
    mac_m1: 2,
    linux: 1,
    windows_wsl2: 3
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
  has_many :learnings, dependent: :destroy
  has_many :pages, dependent: :destroy
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
  has_many :answers,      dependent: :destroy
  has_many :watches, dependent: :destroy
  has_many :articles, dependent: :destroy
  has_many :bookmarks, dependent: :destroy
  has_one :report_template, dependent: :destroy

  has_many :participate_events,
           through: :participations,
           source: :event

  has_many :send_notifications,
           class_name: 'Notification',
           foreign_key: 'sender_id',
           inverse_of: 'sender',
           dependent: :destroy

  has_many :completed_learnings,
           -> { where(status: 'complete') },
           class_name: 'Learning',
           inverse_of: 'user',
           dependent: :destroy

  has_many :completed_practices,
           through: :completed_learnings,
           source: :practice,
           dependent: :destroy

  has_many :active_learnings,
           -> { where(status: 'started') },
           class_name: 'Learning',
           inverse_of: 'user',
           dependent: :destroy

  has_many :active_practices,
           through: :active_learnings,
           source: :practice,
           dependent: :destroy

  has_many :active_relationships,
           class_name: 'Following',
           foreign_key: 'follower_id',
           inverse_of: 'follower',
           dependent: :destroy

  has_many :followees,
           through: :active_relationships,
           source: :followed

  has_many :passive_relationships,
           class_name: 'Following',
           foreign_key: 'followed_id',
           inverse_of: 'followed',
           dependent: :destroy

  has_many :followers,
           through: :passive_relationships,
           source: :follower

  has_one_attached :avatar

  before_create UserCallbacks.new
  after_update UserCallbacks.new

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
  validates :description, presence: true
  validates :nda, presence: true
  validates :password, length: { minimum: 4 }, confirmation: true, if: :password_required?
  validates :twitter_account,
            length: { maximum: 15 },
            format: {
              allow_blank: true,
              with: /\A\w+\z/,
              message: 'は英文字と_（アンダースコア）のみが使用できます'
            }
  validates :mail_notification, inclusion: { in: [true, false] }
  validates :github_id, uniqueness: true, allow_nil: true
  validates :discord_account,
            format: {
              allow_blank: true,
              with: /\A[^\s\p{blank}].*[^\s\p{blank}]#\d{4}\z/,
              message: 'は「ユーザー名#４桁の数字」で入力してください'
            }
  validates :times_url,
            format: {
              allow_blank: true,
              with: %r{\Ahttps://discord\.com/channels/\d+/\d+\z},
              message: 'はDiscordのチャンネルURLを入力してください'
            }

  validates :login_name, exclusion: { in: RESERVED_LOGIN_NAMES, message: 'に使用できない文字列が含まれています' }

  validates :avatar, attached: false,
                     content_type: {
                       in: %w[image/png image/jpg image/jpeg image/gif],
                       message: 'はPNG, JPG, GIF形式にしてください'
                     }

  with_options if: -> { %i[create update].include? validation_context } do
    validates :login_name, presence: true, uniqueness: true,
                           format: {
                             with: /\A[a-z\d](?:[a-z\d]|-(?=[a-z\d]))*\z/i,
                             message: 'は半角英数字と-（ハイフン）のみが使用できます 先頭と最後にハイフンを使用することはできません ハイフンを連続して使用することはできません'
                           }
  end

  with_options if: -> { validation_context != :reset_password && validation_context != :retirement } do
    validates :name_kana,  presence: true,
                           format: {
                             with: /\A[\p{katakana}\p{blank}ー－]+\z/,
                             message: 'はスペースとカタカナのみが使用できます'
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

  flag :retire_reasons, %i[
    done
    necessity
    other_school
    time
    motivation
    curriculum
    support
    environment
    cost
    job_change
    training_end
  ]

  scope :in_school, -> { where(graduated_on: nil) }
  scope :graduated, -> { where.not(graduated_on: nil) }
  scope :retired, -> { where.not(retired_on: nil) }
  scope :unretired, -> { where(retired_on: nil) }
  scope :advisers, -> { where(adviser: true) }
  scope :not_advisers, -> { where(adviser: false) }
  scope :students_and_trainees, lambda {
    where(
      admin: false,
      mentor: false,
      adviser: false,
      graduated_on: nil,
      retired_on: nil
    )
  }
  scope :students, lambda {
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
  scope :inactive, lambda {
    where(
      updated_at: Date.new..1.month.ago,
      adviser: false,
      retired_on: nil,
      graduated_on: nil
    )
  }
  scope :inactive_students_and_trainees, lambda {
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
  scope :working, lambda {
    active.where(
      adviser: false,
      graduated_on: nil,
      retired_on: nil
    ).order(updated_at: :desc)
  }
  scope :admins, -> { where(admin: true) }
  scope :trainees, -> { where(trainee: true) }
  scope :job_seeking, -> { where(job_seeking: true) }
  scope :job_seekers, lambda {
    students.where(
      job_seeker: true
    )
  }
  scope :order_by_counts, lambda { |order_by, direction|
    raise ArgumentError, 'Invalid argument' unless order_by.in?(VALID_SORT_COLUMNS) && direction.in?(VALID_SORT_COLUMNS)

    if order_by.in? %w[report comment]
      left_outer_joins(order_by.pluralize.to_sym)
        .group('users.id')
        .order(Arel.sql("count(#{order_by.pluralize}.id) #{direction}, users.created_at"))
    else
      order(order_by.to_sym => direction.to_sym, created_at: :asc)
    end
  }
  scope :same_generations, lambda { |start_date, end_date|
    where(created_at: start_date..end_date)
      .unretired
      .order(:created_at)
  }
  scope :desc_tagged_with, lambda { |tag_name|
    with_attached_avatar
      .unretired
      .order(updated_at: :desc)
      .tagged_with(tag_name)
  }
  scope :search_by_keywords_scope, -> { unretired }
  scope :delayed, lambda {
    sql = Learning.select(:user_id, 'MAX(updated_at) AS completed_at')
                  .where(status: :complete)
                  .group(:user_id).to_sql

    students_and_trainees
      .joins("JOIN (#{sql}) learnings ON users.id = user_id")
      .select('users.*', :completed_at)
      .where('completed_at <= ?', 2.weeks.ago.end_of_day)
  }

  columns_for_keyword_search(
    :login_name,
    :name,
    :name_kana,
    :twitter_account,
    :facebook_url,
    :blog_url,
    :github_account,
    :discord_account,
    :description
  )

  class << self
    def announcement_receiver(target)
      case target
      when 'all'
        User.unretired
      when 'students'
        User.admins.or(User.students)
      when 'job_seekers'
        User.admins.or(User.job_seekers)
      else
        User.none
      end
    end

    def users_role(target)
      case target
      when 'student_and_trainee'
        students_and_trainees
      when 'graduate'
        graduated
      when 'adviser'
        advisers
      when 'inactive'
        inactive.order(:updated_at)
      when 'trainee'
        trainees
      else
        send(target)
      end
    end

    def tags
      unretired.all_tag_counts(order: 'count desc, name asc')
    end
  end

  def away?
    updated_at <= 10.minutes.ago
  end

  def completed_percentage
    completed_practices_include_progress.size.to_f / practices_include_progress.size * MAX_PERCENTAGE
  end

  def completed_fraction
    "#{completed_practices_include_progress.size}/#{practices_include_progress.size}"
  end

  def completed_practices_hash
    Practice
      .select("count(DISTINCT practices.id) as completed_count, categories_practices.category_id")
      .joins({ categories: :categories_practices }, :learnings)
      .where(
        learnings: {
          user_id: id,
          status: 'complete'
        }
      )
      .group("categories_practices.category_id")
      .each_with_object({}) do |practice, hash|
        hash[practice.category_id] = practice.completed_count
      end
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
      '未登録'
    else
      pref = JpPrefecture::Prefecture.find prefecture_code
      pref.name
    end
  end

  def elapsed_days
    if graduated_on.present?
      (graduated_on.to_date - created_at.to_date).to_i
    else
      (Date.current - created_at.to_date).to_i
    end
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

  def admin_or_mentor?
    admin? || mentor?
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

  def student_or_trainee_or_retired?
    !staff? && !graduated?
  end

  def unread_notifications_count
    @unread_notifications_count ||= notifications.unreads.count
  end

  def unread_notifications_exists?
    unread_notifications_count.positive?
  end

  def avatar_url
    default_image_path = '/images/users/avatars/default.png'
    if avatar.attached?
      avatar.variant(resize: AVATAR_SIZE).processed.url
    else
      image_url default_image_path
    end
  rescue ActiveStorage::FileNotFoundError, ActiveStorage::InvariableError
    image_url default_image_path
  end

  def generation
    (created_at.year - 2013) * 4 + (created_at.month + 2) / 3
  end

  def participating?(event)
    participate_events.include?(event)
  end

  def daimyo?
    company&.name == 'DAIMYO Engineer College'
  end

  def register_github_account(id, account_name)
    self.github_account = account_name
    self.github_id = id
    save!
  end

  def depressed?
    reported_reports = reports.order(reported_on: :desc).limit(DEPRESSED_SIZE)
    reported_reports.size == DEPRESSED_SIZE && reported_reports.all?(&:sad?)
  end

  def active_practice
    active_practice = active_practices.first
    active_practice ? active_practice.id : nil
  end

  def follow(other_user, watch:)
    active_relationships.create(followed: other_user, watch: watch)
  end

  def change_watching(other_user, watch)
    following = Following.find_by(follower_id: self, followed_id: other_user)
    following.update(watch: watch)
  end

  def unfollow(other_user)
    followees.delete(other_user)
  end

  def following?(other_user)
    followees.include?(other_user)
  end

  def watching?(other_user)
    following?(other_user) ? Following.find_by(follower_id: self, followed_id: other_user).watch? : false
  end

  def followees_list(watch: '')
    if %w[true false].include?(watch)
      followees.includes(:passive_relationships).where(followings: { watch: watch })
    else
      followees
    end
  end

  def completed_all_practices?(category)
    category.practices.size == completed_practices_size(category)
  end

  def practices
    course.practices.order('categories.position', 'practices.position')
  end

  def update_mentor_memo(new_memo)
    # ユーザーの「最終ログイン日時」にupdated_at値が利用されるため
    # メンターor管理者によるmemoカラムのupdateの際は、updated_at値の変更を防ぐ
    self.record_timestamps = false
    update!(mentor_memo: new_memo)
  end

  def convert_to_channel_url!
    match = times_url&.match(%r{\Ahttps://discord.gg/(?<invite_code>\w+)\z})
    return if match.nil?

    uri = URI("https://discord.com/api/invites/#{match[:invite_code]}")
    res = Net::HTTP.get_response(uri)

    case res
    when Net::HTTPSuccess
      data = JSON.parse(res.body)
      update!(times_url: "https://discord.com/channels/#{data['guild']['id']}/#{data['channel']['id']}")
    when Net::HTTPNotFound
      logger.warn "[Discord API] 無効な招待URLです: #{login_name} (#{times_url})"
      update!(times_url: nil)
    else
      logger.error "[Discord API] チャンネルURLを取得できません: #{login_name} (#{res.code} #{res.message})"
    end
  end

  private

  def password_required?
    new_record? || password.present?
  end

  def practices_include_progress
    course.practices.where(include_progress: true)
  end

  def completed_practices_include_progress
    practices_include_progress.joins(:learnings)
                              .merge(Learning.complete.where(user_id: id))
  end
end
