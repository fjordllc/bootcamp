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
  include UserStatusScopes
  include UserRoleScopes
  include UserStudentGroupScopes
  include MentorIndexScopes
  include UserActiveScopes
  include UserRegistrationScopes
  include AvatarAttachable
  include UserContentAssociations
  include UserLearningAssociations
  include UserEventAssociations
  include UserFollowAssociations
  include UserRetirement
  include UserAccountAssociations
  include UserJobAndEnvironmentEnums
  include UserCareerEnums
  include UserAccountValidations
  include UserPaymentValidations
  include UserProfileValidations
  include UserSignupValidations
  include UserFlags
  include Ransackable
  include UserCollaborators

  delegate :student?, :current_student?, :staff?, :staff_or_paid?, :admin_or_mentor?,
           :adviser_or_mentor?, :hibernated?, :after_twenty_nine_days_registration?,
           :followup_message_target?, :training_completed?, :retired?, :inactive?,
           :graduated?, :student_or_trainee?, :student_or_trainee_or_retired?,
           :away?, :active?, to: :status
  delegate :card?, :paid?, :subscription?, to: :billing
  delegate :practices_with_checked_product, :practice_ids_skipped, to: :practice_progress
  delegate :submitted?, to: :coding_test_submission
  delegate :elapsed_days, :training_remaining_days, to: :enrollment_period
  delegate :grant_course?, to: :course_grant

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
end
