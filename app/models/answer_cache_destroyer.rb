# frozen_string_literal: true

class AnswerCacheDestroyer
  def call(name, _started, _finished, _unique_id, payload)
    action = name.split('.').last
    answer = payload[:answer]
    Cache.delete_not_solved_question_count
    Rails.logger.info "[AnswerCacheDestroyer] Cache destroyed for unsolved question count. action: #{action}, answer: #{answer.id}"
  end
end
