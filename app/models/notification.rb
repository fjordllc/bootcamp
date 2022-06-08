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
    graduated: 18
  }

  scope :unreads, -> { where(read: false) }
  scope :with_avatar, -> { preload(sender: { avatar_attachment: :blob }) }
  scope :by_read_status, ->(status) { status == 'unread' ? unreads.with_avatar.limit(99) : with_avatar }

  scope :by_target, lambda { |target|
    target ? where(kind: TARGETS_TO_KINDS[target]) : all
  }

  scope :latest_of_each_link, lambda {
    select('DISTINCT ON (link) *').order(link: :asc, created_at: :desc, id: :desc) # 「作成日時が最新の通知」が複数ある場合に取得する1件の通知を一定にするため、ORDER BY の最後に id の降順を指定した
  }

  after_create NotificationCallbacks.new
  after_update NotificationCallbacks.new
  after_destroy NotificationCallbacks.new

  class << self
    def came_comment(comment, receiver, message)
      Notification.create!(
        kind: kinds[:came_comment],
        user: receiver,
        sender: comment.sender,
        link: Rails.application.routes.url_helpers.polymorphic_path(comment.commentable),
        message: message,
        read: false
      )
    end

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

    def mentioned(mentionable, receiver)
      Notification.create!(
        kind: kinds[:mentioned],
        user: receiver,
        sender: mentionable.sender,
        link: mentionable.path,
        message: "#{mentionable.where_mention}で#{mentionable.sender.login_name}さんからメンションがきました。",
        read: false
      )
    end

    def submitted(subject, receiver, message)
      Notification.create!(
        kind: kinds[:submitted],
        user: receiver,
        sender: subject.user,
        link: Rails.application.routes.url_helpers.polymorphic_path(subject),
        message: message,
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

    def post_announcement(announce, receiver)
      Notification.create!(
        kind: kinds[:announced],
        user: receiver,
        sender: announce.sender,
        link: Rails.application.routes.url_helpers.polymorphic_path(announce),
        message: "お知らせ「#{announce.title}」",
        read: false
      )
    end

    def came_question(question, receiver)
      Notification.create!(
        kind: kinds[:came_question],
        user: receiver,
        sender: question.sender,
        link: Rails.application.routes.url_helpers.polymorphic_path(question),
        message: "#{question.user.login_name}さんから質問「#{question.title}」が投稿されました。",
        read: false
      )
    end

    def first_report(report, receiver)
      Notification.create!(
        kind: kinds[:first_report],
        user: receiver,
        sender: report.sender,
        link: Rails.application.routes.url_helpers.polymorphic_path(report),
        message: "🎉 #{report.user.login_name}さんがはじめての日報を書きました！",
        read: false
      )
    end

    def watching_notification(watchable, receiver, comment)
      watchable_user = watchable.user
      sender = comment.user
      Notification.create!(
        kind: kinds[:watching],
        user: receiver,
        sender: sender,
        link: Rails.application.routes.url_helpers.polymorphic_path(watchable),
        message: "#{watchable_user.login_name}さんの【 #{watchable.notification_title} 】に#{comment.user.login_name}さんがコメントしました。",
        read: false
      )
    end

    def retired(sender, receiver)
      Notification.create!(
        kind: kinds[:retired],
        user: receiver,
        sender: sender,
        link: Rails.application.routes.url_helpers.polymorphic_path(sender),
        message: "😢 #{sender.login_name}さんが退会しました。",
        read: false
      )
    end

    def three_months_after_retirement(sender, receiver)
      Notification.create!(
        kind: kinds[:retired],
        user: receiver,
        sender: sender,
        link: Rails.application.routes.url_helpers.polymorphic_path(sender),
        message: "#{I18n.t('.retire_notice', user: sender.login_name)}Discord ID: #{sender.discord_account}, ユーザーページ: https://bootcamp.fjord.jp/users/#{sender.id}",
        read: false
      )
    end

    def trainee_report(report, receiver)
      Notification.create!(
        kind: kinds[:trainee_report],
        user: receiver,
        sender: report.sender,
        link: Rails.application.routes.url_helpers.polymorphic_path(report),
        message: "#{report.user.login_name}さんが日報【 #{report.title} 】を書きました！",
        read: false
      )
    end

    def moved_up_event_waiting_user(event, receiver)
      Notification.create!(
        kind: kinds[:moved_up_event_waiting_user],
        user: receiver,
        sender: event.user,
        link: Rails.application.routes.url_helpers.polymorphic_path(event),
        message: "#{event.title}で、補欠から参加に繰り上がりました。",
        read: false
      )
    end

    def create_page(page, reciever)
      Notification.create!(
        kind: kinds[:create_pages],
        user: reciever,
        sender: page.sender,
        link: Rails.application.routes.url_helpers.polymorphic_path(page),
        message: "#{page.user.login_name}さんがDocsに#{page.title}を投稿しました。",
        read: false
      )
    end

    def following_report(report, receiver)
      Notification.create!(
        kind: kinds[:following_report],
        user: receiver,
        sender: report.sender,
        link: Rails.application.routes.url_helpers.polymorphic_path(report),
        message: "#{report.user.login_name}さんが日報【 #{report.title} 】を書きました！",
        read: false
      )
    end

    def chose_correct_answer(answer, receiver)
      Notification.create!(
        kind: kinds[:chose_correct_answer],
        user: receiver,
        sender: answer.receiver,
        link: Rails.application.routes.url_helpers.polymorphic_path(answer.question),
        message: "#{answer.receiver.login_name}さんの質問【 #{answer.question.title} 】で#{answer.sender.login_name}さんの回答がベストアンサーに選ばれました。",
        read: false
      )
    end

    def product_update(product, receiver)
      Notification.create!(
        kind: 17,
        user: receiver,
        sender: product.user,
        link: Rails.application.routes.url_helpers.polymorphic_path(product),
        message: "#{product.user.login_name}さんの提出物が更新されました",
        read: false
      )
    end
  end

  def unread?
    !read
  end

  def unique?(scope: [])
    !other_duplicates(scope: scope).exists?
  end

  private

  def other_duplicates(scope: [])
    duplicates = scope.inject(Notification.all) { |notifications, scope_item| notifications.where(scope_item => self[scope_item]) }
    duplicates.where.not(id: id)
  end
end
