# frozen_string_literal: true

module Notifiable
  def notification_title
    send("notification_title_for_#{self.class.name.downcase}")
  rescue NoMethodError
    nil
  end

  private

  def notification_title_for_answer
    "#{receiver.login_name}さんのQ&A「#{question.title}」へのコメント"
  end

  def notification_title_for_announcement
    "お知らせ「#{title}」"
  end

  def notification_title_for_comment
    "#{commentable.notification_title}へのコメント"
  end

  def notification_title_for_event
    "特別イベント「#{title}」"
  end

  def notification_title_for_page
    "Docs「#{title}」"
  end

  def notification_title_for_practice
    "プラクティス「#{title}」"
  end

  def notification_title_for_product
    "#{user.login_name}さんの#{title}"
  end

  def notification_title_for_question
    "#{user.login_name}さんのQ&A「#{title}」"
  end

  def notification_title_for_regular_event
    "定期イベント「#{title}」"
  end

  def notification_title_for_report
    "#{user.login_name}さんの日報「#{title}」"
  end

  def notification_title_for_talk
    "#{user.login_name}さんの相談部屋"
  end
end
