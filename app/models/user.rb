# frozen_string_literal: true

class User < ApplicationRecord
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
  include Commentable
  include Billable
  include UserStatusCheck
  include Colleagues
  include Region
  include EventParticipatable
  include PracticeInfo
  include ReportInfo
  include UserAssociations1
  include UserAssociations2
  include UserAssociations3
  include UserAssociations4
  include UserAssociations5
  include UserAssociations6

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

  enum :job, {
    student: 0,
    office_worker: 2,
    part_time_worker: 3,
    vacation: 4,
    unemployed: 5
  }, prefix: true

  enum :os, {
    mac: 0,
    mac_apple: 2,
    linux: 1,
    windows_wsl2: 3
  }, prefix: true

  enum :editor, {
    vscode: 0,
    ruby_mine: 1,
    vim: 2,
    emacs: 3,
    other_editor: 99
  }, prefix: true

  enum :satisfaction, {
    excellent: 0,
    good: 1,
    average: 2,
    poor: 3,
    very_poor: 4
  }, prefix: true

  enum :referral_source, {
    search_engine: 0,
    referral: 1,
    event: 2,
    x: 3,
    facebook: 4,
    blog: 5,
    web_ad: 6,
    other: 99
  }, prefix: true

  enum :career_path, {
    unset: 0,
    job_seeking: 1,
    employed_via_referral: 2,
    employed_without_referral: 3,
    employed_non_it: 4,
    internal_transfer_to_programmer: 5,
    not_employed: 6
  }, prefix: true

  after_create UserCallbacks.new
  before_validation :convert_blank_of_address_to_nil

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
  validates :name, presence: true
  validates :description, presence: true
  validates :nda, presence: true
  validates :password, length: { minimum: 4 }, confirmation: true, if: :password_required?
  validates :mail_notification, inclusion: { in: [true, false] }
  validates :show_mentor_profile, inclusion: { in: [true, false] }
  validates :github_id, uniqueness: true, allow_nil: true
  validates :other_editor, presence: true, if: -> { editor == 'other_editor' }
  validates :other_referral_source, presence: true, if: -> { referral_source == 'other' }
  validates :invoice_payment, inclusion: { in: [true], message: 'にチェックを入れてください。' }, if: -> { role == 'trainee_invoice_payment' }
  validates :invoice_payment, inclusion: { in: [true],
                                           message: 'か「クレジットカード払い」のいずれかを選択してください。' },
                              if: -> { role == 'trainee_select_a_payment_method' && !credit_card_payment }

  validates :facebook_url, :feed_url, :blog_url,
            format: {
              allow_blank: true,
              with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
              message: 'は「http://example.com」や「https://example.com」のようなURL形式で入力してください'
            }

  validates :login_name, exclusion: { in: RESERVED_LOGIN_NAMES, message: 'に使用できない文字列が含まれています' }

  validates :login_name, length: { minimum: 3, message: 'は3文字以上にしてください。' }

  validates :show_study_streak, inclusion: { in: [true, false] }

  validates :diploma_file, content_type: { in: ['application/pdf'], message: 'はPDF形式にしてください' }

  validates :country_code, inclusion: { in: ISO3166::Country.codes }, allow_nil: true

  validates :subdivision_code, inclusion: { in: ->(user) { user.subdivision_codes } }, allow_nil: true, if: -> { country_code.present? }

  with_options if: -> { %i[create update].include? validation_context } do
    validates :login_name, presence: true, uniqueness: true,
                           format: {
                             with: /\A[a-z\d](?:[a-z\d]|-(?=[a-z\d]))*\z/i,
                             message: 'は半角英数字と-（ハイフン）のみが使用できます 先頭と最後にハイフンを使用することはできません ハイフンを連続して使用することはできません'
                           }
  end

  with_options if: -> { !validation_context.in?(%i[reset_password retirement training_completion]) } do
    validates :name_kana, presence: true,
                          format: {
                            with: /\A[\p{katakana}\p{blank}ー－]+\z/,
                            message: 'はスペースとカタカナのみが使用できます'
                          }
  end

  with_options if: -> { !staff? && !validation_context.in?(%i[reset_password retirement training_completion]) } do
    validates :job, presence: true
  end

  with_options if: -> { !adviser? && !validation_context.in?(%i[reset_password retirement training_completion]) } do
    validates :os, presence: true
  end

  with_options if: -> { validation_context.in?(%i[retirement training_completion]) } do
    validates :satisfaction, presence: true
  end

  with_options if: -> { trainee? } do
    validates :company_id, presence: true
  end

  with_options if: -> { !validation_context.in?(%i[retirement training_completion]) } do
    validates :twitter_account,
              length: { maximum: 15 },
              allow_blank: true,
              format: {
                with: /\A\w+\z/,
                message: 'は英文字と_（アンダースコア）のみが使用できます'
              }
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

  flag :experiences, %i[
    html_css
    ruby
    rails
    javascript
    react
    languages_other_than_ruby_and_javascript
  ]

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

  def clear_github_data
    update(
      github_id: nil,
      github_account: nil,
      github_collaborator: false
    )
  end

  def search_title
    login_name
  end

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
