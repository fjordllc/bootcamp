# frozen_string_literal: true

class AiAnswerCreator
  def call(_name, _started, _finished, _unique_id, payload)
    question = payload[:question]
    question.update(ai_answer: '')
    AiAnswerCreateJob.perform_later(question_id: question.id)
  end
end
