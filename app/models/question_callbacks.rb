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
      question.practice.completed_learnings.where.not(user_id: question.sender).eager_load(:user).each do |learning|
        Notification.came_question(question, learning.user)
      end
    end
end