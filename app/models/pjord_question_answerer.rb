# frozen_string_literal: true

class PjordQuestionAnswerer
  def call(_name, _started, _finished, _unique_id, payload)
    question = payload[:question]
    PjordQuestionAnswerJob.perform_later(question_id: question.id)
  end
end
