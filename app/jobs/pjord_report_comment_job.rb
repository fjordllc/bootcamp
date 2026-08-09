# frozen_string_literal: true

class PjordReportCommentJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: :polynomially_longer, attempts: 4
  discard_on ActiveJob::DeserializationError

  def perform(report_id:)
    report = Report.find_by(id: report_id)
    return if report.nil?

    pjord = Pjord.user
    return if pjord.nil?

    add_eyes_reaction(pjord, report)

    intent = classify(report) || 'general'

    response = generate_response(report, intent)
    raise 'Pjord report comment response is blank' if response.blank?

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
    result&.dig(:intent)
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
