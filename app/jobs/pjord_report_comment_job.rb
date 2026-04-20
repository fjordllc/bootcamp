# frozen_string_literal: true

class PjordReportCommentJob < ApplicationJob
  queue_as :default
  discard_on ActiveJob::DeserializationError

  INSTRUCTIONS = <<~TEXT
    日報（学習記録）を読んで、質問や困っている内容があればアドバイスしてください。
    - 日報に質問的な内容や困っている記述がない場合は、他に一切何も書かず [NO_QUESTION] という文字列だけを返してください。挨拶・感想・「質問はありません」等の説明も書かないでください。
    - 質問や困りごとがある場合のみ、通常のコメント（アドバイス）を返してください。その際、コメント本文に「質問なし」「質問はありません」「質問は見当たりません」等の、質問の有無に言及するメタな文言は絶対に含めないでください。生徒宛のアドバイスだけを書いてください。
    - 答えそのものを教えるのではなく、調べ方・ヒント・考え方をアドバイスする
  TEXT

  NO_QUESTION_MARKER = '[NO_QUESTION]'
  NO_QUESTION_PATTERNS = [
    /\A`?\[?NO_QUESTION\]?`?\z/i,
    /\A質問(?:的な内容|らしい内容|事項)?(?:は|も)?(?:特に)?(?:あり(?:ま)?せん|ないです|無いです|なし|見当たり(?:ま)?せん|見受けられ(?:ま)?せん)[。！!.\sねよな～っ]*\z/,
    /\A日報(?:中|内|の中)?に(?:は)?質問.*?(?:あり(?:ま)?せん|ないです|無いです|なし|見当たり(?:ま)?せん)[。！!.\sねよな～っ]*\z/
  ].freeze

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
    return if no_question_response?(response)

    Comment.create!(user: pjord, commentable: report, description: response)
  end

  private

  def no_question_response?(response)
    stripped = response.strip
    NO_QUESTION_PATTERNS.any? { |pattern| stripped.match?(pattern) }
  end

  def build_message(report)
    <<~MESSAGE
      以下の日報を読んで、質問や困っている内容があればアドバイスしてください。
      質問的な内容がなければ [NO_QUESTION] とだけ返答してください。
      コメントを書く場合は、質問の有無に言及するメタな文言（例:「質問なし」「質問はありません」）を本文に一切含めないでください。

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
