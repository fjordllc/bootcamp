# frozen_string_literal: true

class AnswerCacheDestroyer
  def call(answer)
    notify_correct_answer(answer) if answer.saved_change_to_attribute?('type', to: 'CorrectAnswer')
    Cache.delete_not_solved_question_count
  end
end
