# frozen_string_literal: true

class QuestionCallbacks
  def after_create(question)
    send_notification_to_mentors(question)
  end

  def after_destroy(question)
    delete_notification(question)
  end

  private
    def send_notification_to_mentors(question)
      User.mentor.each do |user|
        if question.sender != user
          NotificationFacade.came_question(question, user)
        end
      end
    end

    def delete_notification(question)
      Notification.where(path: "/questions/#{question.id}").destroy_all
    end
end
