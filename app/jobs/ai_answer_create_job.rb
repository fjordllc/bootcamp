# frozen_string_literal: true

class AIAnswerCreateJob < ApplicationJob
  queue_as :default

  def perform(question_id:)
    question = Question.find(question_id)
    generator = AI::AnswerGenerator.new(open_ai_access_token: ENV['OPEN_AI_ACCESS_TOKEN'])
    ai_answer = generator.call("#{question.body}\n#{question.description}")
    question.update(ai_answer: ai_answer)
  end
end
