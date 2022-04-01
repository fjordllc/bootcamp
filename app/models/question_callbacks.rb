# frozen_string_literal: true

class QuestionCallbacks
  def after_save(question)
    return unless question.saved_change_to_attribute?(:published_at, from: nil)

    send_notification_to_mentors(question)
    notify_to_chat(question)
    Cache.delete_not_solved_question_count
  end

  def after_destroy(question)
    delete_notification(question)
    Cache.delete_not_solved_question_count
  end

  private

  def notify_to_chat(question)
    ChatNotifier.message(<<~TEXT)
      質問：#{question.title}が作成されました。
      https://bootcamp.fjord.jp/questions/#{question.id}
    TEXT
  end

  def send_notification_to_mentors(question)
    User.mentor.each do |user|
      NotificationFacade.came_question(question, user) if question.sender != user
    end
  end

  def delete_notification(question)
    Notification.where(link: "/questions/#{question.id}").destroy_all
  end
end
