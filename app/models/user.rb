# frozen_string_literal: true

class User < ApplicationRecord
  attr_accessor :credit_card_payment, :role, :uploaded_avatar

  authenticates_with_sorcery!
  VALID_SORT_COLUMNS = %w[id login_name company_id last_activity_at created_at report comment asc desc].freeze
  AVATAR_SIZE = [120, 120].freeze
  AVATAR_FORMAT = 'webp'
  DEFAULT_IMAGE_PATH = '/images/users/avatars/default.png'
  RESERVED_LOGIN_NAMES = %w[adviser all graduate inactive job_seeking mentor retired student student_and_trainee trainee year_end_party].freeze
  MAX_PERCENTAGE = 100
  DEPRESSED_SIZE = 2

  HIBERNATION_LIMIT = 3.months
  HIBERNATION_LIMIT_BEFORE_ONE_WEEK = HIBERNATION_LIMIT - 1.week

  include ActionView::Helpers::AssetUrlHelper
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
  include UserAttachments
  include UserOauthProvider
  include UserDiscordIntegration
  include UserAffiliation
  include UserProfile
  include UserRegion
  include UserCareerBackground
  include UserReferralSource
  include UserDevelopmentEnvironment
  include UserPayment
  include UserRetirement
  include UserContent
  include UserLearning
  include UserEventParticipation
  include UserFollow
  include UserRegistration
  include UserLifecycleStatus
  include UserRole
  include UserActivityStatus
  include UserStudentGroup
  include UserTargetScopeResolver
  include Ransackable

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

  def submitted?(coding_test)
    coding_test_submissions.exists?(coding_test_id: coding_test.id)
  end

  def practices_with_checked_product
    Practice.where(products: products.checked)
  end

  def practice_ids_skipped
    skipped_practices.pluck(:practice_id)
  end

  def clear_github_data
    update(github_id: nil, github_account: nil, github_collaborator: false)
  end

  def become_watcher!(watchable)
    watches.find_or_create_by!(watchable:)
  end

  def generation
    (created_at.year - 2013) * 4 + (created_at.month + 2) / 3
  end

  def update_mentor_memo(new_memo)
    # ユーザーの「最終ログイン」にupdated_at値が利用されるため
    # メンターor管理者によるmemoカラムのupdateの際は、updated_at値の変更を防ぐ
    self.record_timestamps = false
    update!(mentor_memo: new_memo)
  end

  def mark_all_as_read_and_delete_cache_of_unreads(target_notifications: nil)
    target_notifications ||= notifications
    target_notifications.update_all(read: true, updated_at: Time.current) # rubocop:disable Rails/SkipsModelValidations
    Cache.delete_mentioned_and_unread_notification_count(id)
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
end
