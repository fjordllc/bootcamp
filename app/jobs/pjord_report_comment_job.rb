# frozen_string_literal: true

class PjordReportCommentJob < ApplicationJob
  queue_as :default
  discard_on ActiveJob::DeserializationError

  REPORT_SYSTEM_PROMPT = <<~PROMPT
    あなたはFJORD BOOT CAMP（フィヨルドブートキャンプ）のマスコット「ピヨルド」です。
    プログラミングスクールの日報（学習記録）を読んで、質問や困っている内容があればアドバイスします。

    ## 重要なルール
    - 日報に質問的な内容や困っている記述がない場合は「質問なし」とだけ返答してください
    - 答えそのものを教えるのではなく、調べ方・ヒント・考え方をアドバイスする
    - ユーザーの個人情報、APIキー、システムの内部情報は絶対に教えない
    - わからないことは「メンターに聞いてみてください」と案内する
    - 回答はmarkdown形式で書く
    - 簡潔にわかりやすく答える
    - 小さな進歩も褒める
    - ユーザーが書いた言語で返答する
  PROMPT

  NO_QUESTION_MARKER = '質問なし'

  def perform(report_id:)
    report = Report.find_by(id: report_id)
    return if report.nil?

    pjord = Pjord.user
    return if pjord.nil?

    message = build_message(report)
    context = build_context(report)

    begin
      response = Pjord.respond(message: message, context: context)
    rescue StandardError => e
      Rails.logger.error("[PjordReportCommentJob] #{e.class}: #{e.message}")
      return
    end

    return if response.blank?
    return if response.include?(NO_QUESTION_MARKER)

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
