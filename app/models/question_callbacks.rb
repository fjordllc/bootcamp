# frozen_string_literal: true

class QuestionCallbacks
  def after_save(question)
    return unless question.saved_change_to_attribute?(:published_at, from: nil)

    send_notification_to_mentors(question)
    Rails.logger.info '[CACHE CLEARED#after_save] Cache destroyed for unsolved question count.'
    Cache.delete_not_solved_question_count
  end

  def before_destroy(question)
    return unless question.not_wip? && question.unsolved?

    Cache.delete_not_solved_question_count
    Rails.logger.info '[CACHE CLEARED#before_destroy] Cache destroyed for unsolved question count.'
  end

  def after_destroy(question)
    delete_notification(question)
  end

  private

  def send_notification_to_mentors(question)
    User.mentor.each do |user|
      ActivityDelivery.with(sender: question.user, receiver: user, question:).notify(:came_question) if question.sender != user
    end
  end

  def delete_notification(question)
    Notification.where(link: "/questions/#{question.id}").destroy_all
  end
end
