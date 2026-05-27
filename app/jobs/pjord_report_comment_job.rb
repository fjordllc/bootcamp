# frozen_string_literal: true

class PjordReportCommentJob < ApplicationJob
  queue_as :default
  discard_on ActiveJob::DeserializationError

  def perform(report_id:)
    report = Report.find_by(id: report_id)
    return if report.nil?

    pjord = Pjord.user
    return if pjord.nil?

    add_eyes_reaction(pjord, report)

    intent = classify(report)
    return if intent == 'none'

    response = generate_response(report, intent)
    return if response.blank?

    Comment.create!(user: pjord, commentable: report, description: response)
  end

  private

  def add_eyes_reaction(pjord, report)
    Reaction.find_or_create_by!(user: pjord, reactionable: report, kind: :eyes)
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => e
    Rails.logger.error("[PjordReportCommentJob] reaction failed: #{e.class}: #{e.message}")
  end

  def classify(report)
    result = Pjord::ReportClassifierAgent.classify(report)
    intent = result&.dig(:intent)
    return 'none' if intent.nil?

    intent
  rescue StandardError => e
    Rails.logger.error("[PjordReportCommentJob] classify failed: #{e.class}: #{e.message}")
    raise
  end

  def generate_response(report, intent)
    Pjord::ReportCommentAgent.comment(report, intent:)
  rescue StandardError => e
    Rails.logger.error("[PjordReportCommentJob] respond failed: #{e.class}: #{e.message}")
    raise
  end
end
