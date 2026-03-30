# frozen_string_literal: true

class PjordQuestionAnswerJob < ApplicationJob
  queue_as :default
  discard_on ActiveJob::DeserializationError

  def perform(question_id:)
    question = Question.find_by(id: question_id)
    return if question.nil?

    pjord = Pjord.user
    return if pjord.nil?

    context = build_context(question)
    message = "#{question.title}\n#{question.description}"

    begin
      response = Pjord.respond(message: message, context: context)
    rescue StandardError => e
      Rails.logger.error("[PjordQuestionAnswerJob] #{e.class}: #{e.message}")
      return
    end

    return if response.blank?

    Answer.create!(user: pjord, question: question, description: response)
  end

  private

  def build_context(question)
    context = {}
    context[:location] = question.where_mention
    context[:practice] = question.practice&.title
    context
  end
end
