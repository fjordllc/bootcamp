# frozen_string_literal: true

class QuestionCallbacks
  def after_save(question)
    return unless question.wip == false && question.published_at.nil?

    send_notification_to_mentors(question)
    Cache.delete_not_solved_question_count

    question.published_at = Time.current
    question.save
  end

  def after_destroy(question)
    delete_notification(question)
    Cache.delete_not_solved_question_count
  end

  private

  def send_notification_to_mentors(question)
    User.mentor.each do |user|
      NotificationFacade.came_question(question, user) if question.sender != user
    end
  end

  def delete_notification(question)
    Notification.where(link: "/questions/#{question.id}").destroy_all
  end
end
