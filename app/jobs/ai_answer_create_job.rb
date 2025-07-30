# frozen_string_literal: true

class AIAnswerCreateJob < ApplicationJob
  queue_as :default

  def perform(question_id:)
    question = Question.find(question_id)
    token = ENV['OPEN_AI_ACCESS_TOKEN']
    generator = AI::AnswerGenerator.new(open_ai_access_token: token)
    ai_answer = generator.call("#{question.body}\n#{question.description}")
    question.update(ai_answer:)
  end
end
