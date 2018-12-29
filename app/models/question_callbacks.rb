# frozen_string_literal: true

class QuestionCallbacks
  def after_create(question)
    send_notification(question)
  end

  private
    def send_notification(question)
      User.mentor.each do |user|
        if question.sender != user
          Notification.came_question(question, user)
        end
      end
      question.practice.completed_learnings.each do |learning|
        if learning.user != question.sender
          Notification.came_question(question, learning.user)
        end
      end
    end
end
