# frozen_string_literal: true

class AIAnswerCreateJob < ApplicationJob
  queue_as :default

  def perform(question_id:)
    question = Question.find(question_id)
    token = Rails.application.config_for(:secrets)[:open_ai][:access_token]
    generator = AI::AnswerGenerator.new(open_ai_access_token: token)
    ai_answer = generator.call("#{question.body}\n#{question.description}")
    question.update(ai_answer:)
  end
end
