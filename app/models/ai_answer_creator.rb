# frozen_string_literal: true

class AIAnswerCreator
  def call(_name, _started, _finished, _unique_id, payload)
    question = payload[:question]
    question.update(ai_answer: '')
    AIAnswerCreateJob.perform_later(question_id: question.id)
  end
end
