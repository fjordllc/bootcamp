# frozen_string_literal: true

class AnswerCacheDestroyer
  def call(_name, _started, _finished, _unique_id, payload)
    _answer = payload[:answer]
    Cache.delete_not_solved_question_count
  end
end
