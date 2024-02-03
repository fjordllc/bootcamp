# frozen_string_literal: true

class AnswerCacheDestroyer
  def call(payload)
    _answer = payload[:answer]
    Cache.delete_not_solved_question_count
  end
end
