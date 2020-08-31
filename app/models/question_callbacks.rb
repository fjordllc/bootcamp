# frozen_string_literal: true

class QuestionCallbacks
  def after_create(question)
    send_notification_to_mentors(question)
    Cache.delete_not_solved_question_count
  end

  def after_destroy(question)
    delete_notification(question)
    Cache.delete_not_solved_question_count
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
