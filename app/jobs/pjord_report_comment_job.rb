# frozen_string_literal: true

class PjordReportCommentJob < ApplicationJob
  queue_as :default
  discard_on ActiveJob::DeserializationError

  INSTRUCTIONS = <<~TEXT
    日報（学習記録）を読んで、応答内容を pjord_report_response_tool ツールを使って返してください。

    - 日報に質問や困っている記述がない場合は、ツールを action="skip" で呼んでください。
    - 質問や困りごとがある場合は、ツールを action="post" で呼び、advice にアドバイス本文（markdown形式、生徒宛）を渡してください。
    - advice には「質問なし」「質問はありません」等のメタな文言は含めず、生徒宛のアドバイスだけを書いてください。
    - 答えそのものを教えるのではなく、調べ方・ヒント・考え方をアドバイスしてください。
    - 必要に応じて bootcamp_search_tool や user_info_tool で情報を集めたあと、最後に pjord_report_response_tool を呼んで応答を確定してください。
  TEXT

  def perform(report_id:)
    report = Report.find_by(id: report_id)
    return if report.nil?

    pjord_user = Pjord.user
    return if pjord_user.nil?

    response_tool = PjordReportResponseTool.new

    begin
      chat = Pjord.build_chat(
        context: build_context(report),
        instructions: INSTRUCTIONS,
        extra_tools: [response_tool]
      )
      chat.ask(build_message(report))
    rescue StandardError => e
      Rails.logger.error("[PjordReportCommentJob] #{e.class}: #{e.message}")
      return
    end

    return unless response_tool.post?

    Comment.create!(user: pjord_user, commentable: report, description: response_tool.advice)
  end

  private

  def build_message(report)
    <<~MESSAGE
      以下の日報を読んで、pjord_report_response_tool で応答を返してください。

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
