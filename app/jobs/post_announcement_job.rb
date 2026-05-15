# frozen_string_literal: true

class PostAnnouncementJob < ApplicationJob
  queue_as :default

  def perform(announcement, receivers)
    receivers.each do |receiver|
      send_on_site_notification(announcement, receiver)
      send_mail_notification(announcement, receiver)
    end
  end

  private

  def send_mail_notification(announcement, receiver)
    ActivityMailer.post_announcement(announcement:, receiver:).deliver_now
  rescue Postmark::InactiveRecipientError => e
    Rails.logger.warn "[Postmark] 受信者由来のエラーのためメールを送信できませんでした。：#{e.message}"
  rescue StandardError => e
    Rails.logger.warn(e)
  end

  def send_on_site_notification(announcement, receiver)
    Notification.create!(
      kind: Notification.kinds[:announced],
      user: receiver,
      sender: announcement.sender,
      link: Rails.application.routes.url_helpers.polymorphic_path(announcement),
      message: "お知らせ「#{announcement.title}」",
      read: false
    )
  rescue StandardError => e
    Rails.logger.warn(e)
  end
end
