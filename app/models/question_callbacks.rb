# frozen_string_literal: true

class QuestionCallbacks
  def after_create(question)
    send_notification(question)
  end

  private
    def send_notification(question)
      User.mentor.each do |user|
        Notification.came_question(question, user)
      end
    end
end
