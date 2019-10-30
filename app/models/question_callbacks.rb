# frozen_string_literal: true

class QuestionCallbacks
  def after_create(question)
    send_notification_to_mentors(question)
    send_notification_to_completed_students(question)
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

    def send_notification_to_completed_students(question)
      question.practice.completed_learnings.where.not(user_id: question.sender).eager_load(:user).each do |learning|
        NotificationFacade.came_question(question, learning.user)
      end
    end

    def delete_notification(question)
      Notification.where(path: "/questions/#{question.id}").destroy_all
    end
end
