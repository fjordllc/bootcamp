# frozen_string_literal: true

class AIAnswerCreator
  def call(payload)
    question = payload[:question]
    question.update(ai_answer: '')
    AIAnswerCreateJob.perform_later(question_id: question.id)
  end
end
