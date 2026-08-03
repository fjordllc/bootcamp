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
  ALL_ALLOWED_TARGETS = %w[adviser all campaign graduate hibernated inactive job_seeking mentor retired student_and_trainee student trainee
                           year_end_party admin].freeze
  # 本来であればtarget = scope名としたいが、歴史的経緯によりtargetとscope名が一致しないものが多数あるため、名前が一致しない場合はこのハッシュを使ってscope名に変換する
  TARGET_TO_SCOPE = {
    'student_and_trainee' => :students_and_trainees,
    'student' => :students,
    'trainee' => :trainees,
    'graduate' => :graduated,
    'adviser' => :advisers,
    'admin' => :admins
  }.freeze
  HIBERNATION_LIMIT = 3.months
  HIBERNATION_LIMIT_BEFORE_ONE_WEEK = HIBERNATION_LIMIT - 1.week
  INVITATION_ROLES = [
    [I18n.t('invitation_role.adviser'), :adviser],
    [I18n.t('invitation_role.trainee', payment_method: '請求書払い'), :trainee_invoice_payment],
    [I18n.t('invitation_role.trainee', payment_method: 'クレジットカード払い'), :trainee_credit_card_payment],
    [I18n.t('invitation_role.trainee', payment_method: '支払い方法を選択'), :trainee_select_a_payment_method],
    [I18n.t('invitation_role.mentor'), :mentor]
  ].freeze

  include ActionView::Helpers::AssetUrlHelper
  include Taggable
  include Searchable
  include StagingEnvironment
  include UserStatusScopes
  include UserRoleScopes
  include UserStudentGroupScopes
  include MentorIndexScopes
  include UserActiveScopes
  include UserSimpleQueryScopes
  include UserComplexQueryScopes
  include AvatarAttachable
  include FollowerAndWatcher
  include Comebackable
  include Billable
  include UserStatusCheck
  include Colleagues
  include Region
  include EventParticipatable
  include PracticeInfo
  include ReportInfo
  include UserContentAssociations
  include UserLearningAssociations
  include UserPracticeProgressAssociations
  include UserEventAssociations
  include UserFollowAssociations
  include UserRetirementAssociations
  include UserAccountAssociations
  include UserJobAndEnvironmentEnums
  include UserCareerEnums
  include UserAccountValidations
  include UserPaymentValidations
  include UserProfileValidations
  include UserSignupValidations
  include UserRetirementValidations
  include UserFlags
  include Ransackable

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

  private

  def password_required?
    new_record? || password.present?
  end

  def convert_blank_of_address_to_nil
    self.country_code = nil if country_code.blank?
    self.subdivision_code = nil if subdivision_code.blank?
  end

  def role_for_thanks_page
    return 'adviser' if adviser?
    return 'trainee' if trainee?
    return 'mentor' if mentor?

    'student'
  end
end
