# frozen_string_literal: true

class AnswerCacheDestroyer
  def call(payload)
    _answer = payload[:answer]
    Cache.delete_not_solved_question_count
    Rails.logger.info '[AnswerCacheDestroyer] Cache destroyed for unsolved question count.'
  end
end
