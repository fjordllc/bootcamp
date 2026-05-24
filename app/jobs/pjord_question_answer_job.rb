# frozen_string_literal: true

class PjordQuestionAnswerJob < ApplicationJob
  queue_as :default
  discard_on ActiveJob::DeserializationError

  def perform(question_id:)
    question = Question.find_by(id: question_id)
    return if question.nil?

    pjord = Pjord.user
    return if pjord.nil?

    begin
      response = Pjord::QuestionAnswerAgent.answer(question)
    rescue StandardError => e
      Rails.logger.error("[PjordQuestionAnswerJob] #{e.class}: #{e.message}")
      return
    end

    return if response.blank?

    Answer.create!(user: pjord, question: question, description: response)
  end
end
