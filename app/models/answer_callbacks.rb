# frozen_string_literal: true

class AnswerCallbacks
  def after_save(answer)
    notify_correct_answer(answer) if answer.saved_change_to_attribute?('type', to: 'CorrectAnswer')

    Cache.delete_not_solved_question_count
  end

  def after_destroy(_answer)
    Cache.delete_not_solved_question_count
  end

  private

  def notify_correct_answer(answer)
    question = answer.question
    watcher_ids = question.watches.pluck(:user_id)
    receiver_ids = watcher_ids - [question.user_id]
    receiver_ids.each do |receiver_id|
      receiver = User.find(receiver_id)
      NotificationFacade.chose_correct_answer(answer, receiver)
    end
  end
end
