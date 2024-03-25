# frozen_string_literal: true

class Notification < ApplicationRecord
  TARGETS_TO_KINDS = {
    announcement: [:announced],
    mention: [:mentioned],
    comment: %i[came_comment answered],
    check: %i[checked assigned_as_checker product_update],
    watching: [:watching],
    following_report: [:following_report]
  }.freeze

  belongs_to :user
  belongs_to :sender, class_name: 'User'

  paginates_per 20

  enum kind: {
    came_comment: 0,
    checked: 1,
    mentioned: 2,
    submitted: 3,
    answered: 4,
    announced: 5,
    came_question: 6,
    first_report: 7,
    watching: 8,
    retired: 9,
    trainee_report: 10,
    moved_up_event_waiting_user: 11,
    create_pages: 12,
    following_report: 13,
    chose_correct_answer: 14,
    consecutive_sad_report: 15,
    assigned_as_checker: 16,
    product_update: 17,
    graduated: 18,
    hibernated: 19,
    signed_up: 20,
    regular_event_updated: 21,
    no_correct_answer: 22,
    comebacked: 23
  }

  scope :unreads, -> { where(read: false) }
  scope :with_avatar, -> { preload(sender: { avatar_attachment: :blob }) }
  scope :by_read_status, ->(status) { status == 'unread' ? unreads.with_avatar : with_avatar }
  scope :by_target, ->(target) { target.presence ? where(kind: TARGETS_TO_KINDS[target.to_sym]) : all }

  # 作成日時が被ったら、最新idのレコードを取得したい
  scope :latest_of_each_link, -> { select('DISTINCT ON (link) *').order(link: :asc, created_at: :desc, id: :desc) }

  after_create NotificationCallbacks.new
  after_update NotificationCallbacks.new
  after_destroy NotificationCallbacks.new

  class << self
    def checked(check)
      Notification.create!(
        kind: kinds[:checked],
        user: check.receiver,
        sender: check.sender,
        link: Rails.application.routes.url_helpers.polymorphic_path(check.checkable),
        message: "#{check.sender.login_name}さんが#{check.checkable.title}を確認しました。",
        read: false
      )
    end

    def came_answer(answer)
      Notification.create!(
        kind: kinds[:answered],
        user: answer.receiver,
        sender: answer.sender,
        link: Rails.application.routes.url_helpers.polymorphic_path(answer.question),
        message: "#{answer.user.login_name}さんから回答がありました。",
        read: false
      )
    end
  end

  def unread?
    !read
  end

  def unique?(scope: [])
    !other_duplicates(scope:).exists?
  end

  private

  def other_duplicates(scope: [])
    duplicates = scope.inject(Notification.all) { |notifications, scope_item| notifications.where(scope_item => self[scope_item]) }
    duplicates.where.not(id:)
  end
end
