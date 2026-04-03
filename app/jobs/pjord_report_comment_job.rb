# frozen_string_literal: true

class PjordReportCommentJob < ApplicationJob
  queue_as :default
  discard_on ActiveJob::DeserializationError

  INSTRUCTIONS = <<~TEXT
    日報（学習記録）を読んで、質問や困っている内容があればアドバイスしてください。
    - 日報に質問的な内容や困っている記述がない場合は「質問なし」とだけ返答してください
    - 答えそのものを教えるのではなく、調べ方・ヒント・考え方をアドバイスする
  TEXT

  NO_QUESTION_MARKER = '質問なし'

  def perform(report_id:)
    report = Report.find_by(id: report_id)
    return if report.nil?

    pjord = Pjord.user
    return if pjord.nil?

    message = build_message(report)
    context = build_context(report)

    begin
      response = Pjord.respond(message: message, context: context, instructions: INSTRUCTIONS)
    rescue StandardError => e
      Rails.logger.error("[PjordReportCommentJob] #{e.class}: #{e.message}")
      return
    end

    return if response.blank?
    return if response.strip.start_with?(NO_QUESTION_MARKER)

    Comment.create!(user: pjord, commentable: report, description: response)
  end

  private

  def build_message(report)
    <<~MESSAGE
      以下の日報を読んで、質問や困っている内容があればアドバイスしてください。
      質問的な内容がなければ「質問なし」とだけ返答してください。

      ## 日報タイトル
      #{report.title}

      ## 日報本文
      #{report.description}
    MESSAGE
  end

  def build_context(report)
    practices = report.practices.map(&:title).join(', ')
    {
      location: '日報',
      practice: practices.presence,
      sender_login_name: report.user.login_name
    }
  end
end
