# frozen_string_literal: true

class Notification < ApplicationRecord
  TARGETS_TO_KINDS = {
    announcement: [:announced],
    mention: [:mentioned],
    comment: %i[came_comment answered],
    check: [:checked],
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
    consecutive_sad_report: 15
  }

  after_create NotificationCallbacks.new
  after_update NotificationCallbacks.new

  scope :reads, lambda {
    where(created_at: into_one.values).order(created_at: :desc)
  }

  scope :unreads, lambda {
    where(read: false, created_at: into_one.values).order(created_at: :desc)
  }

  scope :with_avatar, -> { preload(sender: { avatar_attachment: :blob }) }
  scope :by_read_status, ->(status) { status == 'unread' ? unreads.with_avatar.limit(99) : reads.with_avatar }

  scope :by_target, lambda { |target|
    target ? where(kind: TARGETS_TO_KINDS[target]) : all
  }

  def self.came_comment(comment, receiver, message)
    Notification.create!(
      kind: 0,
      user: receiver,
      sender: comment.sender,
      path: Rails.application.routes.url_helpers.polymorphic_path(comment.commentable),
      message: message,
      read: false
    )
  end

  def self.checked(check)
    Notification.create!(
      kind: 1,
      user: check.receiver,
      sender: check.sender,
      path: Rails.application.routes.url_helpers.polymorphic_path(check.checkable),
      message: "#{check.sender.login_name}さんが#{check.checkable.title}を確認しました。",
      read: false
    )
  end

  def self.mentioned(mentionable, receiver)
    Notification.create!(
      kind: 2,
      user: receiver,
      sender: mentionable.sender,
      path: mentionable.path,
      message: "#{mentionable.sender.login_name}さんからメンションがきました。",
      read: false
    )
  end

  def self.submitted(subject, receiver, message)
    Notification.create!(
      kind: 3,
      user: receiver,
      sender: subject.user,
      path: Rails.application.routes.url_helpers.polymorphic_path(subject),
      message: message,
      read: false
    )
  end

  def self.came_answer(answer)
    Notification.create!(
      kind: 4,
      user: answer.receiver,
      sender: answer.sender,
      path: Rails.application.routes.url_helpers.polymorphic_path(answer.question),
      message: "#{answer.user.login_name}さんから回答がありました。",
      read: false
    )
  end

  def self.post_announcement(announce, receiver)
    Notification.create!(
      kind: 5,
      user: receiver,
      sender: announce.sender,
      path: Rails.application.routes.url_helpers.polymorphic_path(announce),
      message: "お知らせ「#{announce.title}」",
      read: false
    )
  end

  def self.came_question(question, receiver)
    Notification.create!(
      kind: 6,
      user: receiver,
      sender: question.sender,
      path: Rails.application.routes.url_helpers.polymorphic_path(question),
      message: "#{question.user.login_name}さんから質問がありました。",
      read: false
    )
  end

  def self.first_report(report, receiver)
    Notification.create!(
      kind: 7,
      user: receiver,
      sender: report.sender,
      path: Rails.application.routes.url_helpers.polymorphic_path(report),
      message: "#{report.user.login_name}さんがはじめての日報を書きました！",
      read: false
    )
  end

  def self.watching_notification(watchable, receiver, comment)
    watchable_user = watchable.user
    sender = comment.user
    Notification.create!(
      kind: 8,
      user: receiver,
      sender: sender,
      path: Rails.application.routes.url_helpers.polymorphic_path(watchable),
      message: "#{watchable_user.login_name}さんの【 #{watchable.notification_title} 】に#{comment.user.login_name}さんがコメントしました。",
      read: false
    )
  end

  def self.retired(sender, receiver)
    Notification.create!(
      kind: 9,
      user: receiver,
      sender: sender,
      path: Rails.application.routes.url_helpers.polymorphic_path(sender),
      message: "#{sender.login_name}さんが退会しました。",
      read: false
    )
  end

  def self.trainee_report(report, receiver)
    Notification.create!(
      kind: 10,
      user: receiver,
      sender: report.sender,
      path: Rails.application.routes.url_helpers.polymorphic_path(report),
      message: "#{report.user.login_name}さんが日報【 #{report.title} 】を書きました！",
      read: false
    )
  end

  def self.moved_up_event_waiting_user(event, receiver)
    Notification.create!(
      kind: 11,
      user: receiver,
      sender: event.user,
      path: Rails.application.routes.url_helpers.polymorphic_path(event),
      message: "#{event.title}で、補欠から参加に繰り上がりました。",
      read: false
    )
  end

  def self.create_page(page, reciever)
    Notification.create!(
      kind: 12,
      user: reciever,
      sender: page.sender,
      path: Rails.application.routes.url_helpers.polymorphic_path(page),
      message: "#{page.user.login_name}さんがDocsに#{page.title}を投稿しました。",
      read: false
    )
  end

  def self.following_report(report, receiver)
    Notification.create!(
      kind: 13,
      user: receiver,
      sender: report.sender,
      path: Rails.application.routes.url_helpers.polymorphic_path(report),
      message: "#{report.user.login_name}さんが日報【 #{report.title} 】を書きました！",
      read: false
    )
  end

  def self.chose_correct_answer(answer, receiver)
    Notification.create!(
      kind: 14,
      user: receiver,
      sender: answer.receiver,
      path: Rails.application.routes.url_helpers.polymorphic_path(answer.question),
      message: "#{answer.receiver.login_name}さんの質問【 #{answer.question.title} 】で#{answer.sender.login_name}さんの回答がベストアンサーに選ばれました。",
      read: false
    )
  end

  def self.consecutive_sad_report(report, receiver)
    Notification.create!(
      kind: 15,
      user: receiver,
      sender: report.sender,
      path: Rails.application.routes.url_helpers.polymorphic_path(report),
      message: "#{report.user.login_name}さんが#{User::DEPRESSED_SIZE}回連続でsadアイコンの日報を提出しました。",
      read: false
    )
  end

  def self.into_one
    select(:path).group(:path).maximum(:created_at)
  end
end
