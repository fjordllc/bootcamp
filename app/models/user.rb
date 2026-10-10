# frozen_string_literal: true

class User < ApplicationRecord # rubocop:todo Metrics/ClassLength
  attr_accessor :credit_card_payment, :role, :uploaded_avatar

  authenticates_with_sorcery!
  VALID_SORT_COLUMNS = %w[id login_name company_id last_activity_at created_at report comment asc desc].freeze
  RESERVED_LOGIN_NAMES = %w[adviser all graduate inactive job_seeking mentor retired student student_and_trainee trainee year_end_party].freeze
  MAX_PERCENTAGE = 100
  DEPRESSED_SIZE = 2

  HIBERNATION_LIMIT = 3.months
  HIBERNATION_LIMIT_BEFORE_ONE_WEEK = HIBERNATION_LIMIT - 1.week

  include Taggable
  include Searchable

  columns_for_keyword_search(
    :login_name,
    :name,
    :name_kana,
    :twitter_account,
    :facebook_url,
    :blog_url,
    :github_account,
    :description
  )

  include StagingEnvironment
  include UserAuthentication
  include UserOauthProvider
  include UserDiscordIntegration
  include UserAffiliation
  include UserProfile
  include UserLoginName
  include UserRegion
  include UserMentorMemo
  include UserCareerBackground
  include UserReferralSource
  include UserDevelopmentEnvironment
  include UserPayment
  include UserRetirement
  include UserLearning
  include UserEventParticipation
  include UserFollow
  include UserNotification
  include UserLifecycleStatus
  include UserRole
  include UserActivityStatus
  include UserStudentGroup

  def self.ransackable_attributes(_auth_object = nil)
    %w[
      login_name name name_kana email twitter_account facebook_url
      blog_url github_account description profile_text
      created_at updated_at last_activity_at
      company_id course_id graduated_on retired_on
      admin mentor adviser trainee job_seeker hibernated_at
      experiences career_path job os editor subdivision_code country_code
    ]
  end

  def self.ransackable_scopes(_auth_object = nil)
    %i[job_seeking]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[company course discord_profile]
  end

  has_one_attached :avatar
  has_one_attached :profile_image
  has_one_attached :diploma_file

  validates :uploaded_avatar, avatar_content_type: true
  validates :diploma_file, content_type: { in: ['application/pdf'], message: 'はPDF形式にしてください' }

  has_many :pages, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :reports, dependent: :destroy
  has_many :articles, dependent: :destroy
  has_many :questions, dependent: :destroy
  has_many :announcements, dependent: :destroy
  has_many :movies, dependent: :nullify
  has_many :micro_reports, dependent: :destroy
  has_many :authored_micro_reports, class_name: 'MicroReport', foreign_key: 'comment_user_id', dependent: :destroy, inverse_of: :comment_user
  has_many :surveys, dependent: :destroy
  has_many :survey_questions, dependent: :destroy
  has_many :authored_books, dependent: :destroy
  accepts_nested_attributes_for :authored_books, allow_destroy: true
  has_one :talk, dependent: :destroy
  has_one :report_preset, dependent: :destroy
  has_many :images, dependent: :destroy
  has_many :works, dependent: :destroy
  has_many :external_entries, dependent: :destroy
  has_many :watches, dependent: :destroy
  has_many :reactions, dependent: :destroy
  has_many :footprints, dependent: :destroy
  has_many :answers, dependent: :destroy
  has_many :bookmarks, dependent: :destroy

  after_create UserCallbacks.new

  scope :classmates, ->(start_date, end_date) { where(created_at: start_date..end_date).order(:created_at, :id) }
  scope :campaign, -> { where(created_at: Campaign.recently_campaign) }
  scope :year_end_party, -> { YearEndPartyTargetsQuery.new(all).call }

  validates :nda, presence: true

  delegate :card?, :paid?, :subscription?, to: :billing
  delegate :elapsed_days, :training_remaining_days, to: :enrollment_period
  delegate :depressed?, :raw_last_negative_report_id, :update_negative_streak, to: :negative_streak_tracker
  delegate :wip_exists?, to: :wip_content
  delegate :latest_micro_report_page, to: :micro_report_pagination
  delegate :hibernation_elapsed_days, :scheduled_retire_at, to: :hibernation
  delegate :reports_with_learning_times, to: :learning_time
  delegate :follow, :unfollow, :following?, :followees_list, :change_watching, :watching?, to: :follows
  delegate :colleagues, :colleagues_other_than_self, :colleague_trainees, to: :colleagues_finder
  delegate :country_name, :subdivision_name, :subdivision_codes, :area, to: :region
  delegate :participating?, :unfinished_participated_regular_events, :involved_events, :involved_regular_events, to: :event_involvement
  delegate :clean_up_regular_events, to: :regular_event_cleanup
  delegate :avatar_url, :profile_image_url, to: :avatar_handler

  def course_practice
    UserCoursePractice.new(self)
  end

  def learning_time
    UserLearningTime.new(self)
  end

  def hibernation
    UserHibernation.new(self)
  end

  def followup_message_target?
    UserFollowupEligibility.new(self).eligible?
  end

  def grant_course?
    course&.grant?
  end

  def clear_github_data
    update(github_id: nil, github_account: nil, github_collaborator: false)
  end

  def become_watcher!(watchable)
    watches.find_or_create_by!(watchable:)
  end

  def generation
    Generation.generation_number_for(created_at)
  end

  def search_title
    login_name
  end

  def belongs_company_and_adviser?
    adviser? && company_id?
  end

  private

  def billing
    UserBilling.new(self)
  end

  def enrollment_period
    UserEnrollmentPeriod.new(self)
  end

  def negative_streak_tracker
    UserNegativeStreak.new(self)
  end

  def wip_content
    UserWipContent.new(self)
  end

  def micro_report_pagination
    UserMicroReportPagination.new(self)
  end

  def follows
    UserFollows.new(self)
  end

  def colleagues_finder
    UserColleagues.new(self)
  end

  def region
    GeoRegion.new(country_code, subdivision_code)
  end

  def event_involvement
    UserEventInvolvement.new(self)
  end

  def regular_event_cleanup
    UserRegularEventCleanup.new(self)
  end

  def avatar_handler
    UserAvatar.new(self)
  end
end
