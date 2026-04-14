# frozen_string_literal: true

class PjordReportCommentJob < ApplicationJob
  queue_as :default
  discard_on ActiveJob::DeserializationError

  INSTRUCTIONS_BY_INTENT = {
    'question' => <<~TEXT,
      日報に質問や詰まっている記述があります。
      答えそのものを教えるのではなく、調べ方・ヒント・考え方をアドバイスしてください。
    TEXT
    'struggling' => <<~TEXT,
      日報から、落ち込み・焦り・疲労・挫折感などネガティブな感情が読み取れます。
      まず気持ちに寄り添って共感し、小さな進歩を見つけて励ましてください。
      無理にアドバイスを押し付けず、短めのコメントで構いません。
    TEXT
    'celebration' => <<~TEXT
      日報から、大きな達成・ブレイクスルー・喜びが読み取れます。
      その達成を具体的に褒め、一緒に喜ぶコメントを書いてください。
      次の学習への前向きな一言を添えても構いません。
    TEXT
  }.freeze

  def perform(report_id:)
    report = Report.find_by(id: report_id)
    return if report.nil?

    pjord = Pjord.user
    return if pjord.nil?

    intent = classify(report)
    return if intent.nil? || intent == 'none'

    response = generate_response(report, intent)
    return if response.blank?

    Comment.create!(user: pjord, commentable: report, description: response)
  end

  private

  def classify(report)
    result = Pjord.classify_report(title: report.title, description: report.description)
    result&.dig(:intent)
  rescue StandardError => e
    Rails.logger.error("[PjordReportCommentJob] classify failed: #{e.class}: #{e.message}")
    raise
  end

  def generate_response(report, intent)
    message = build_message(report)
    context = build_context(report)
    instructions = INSTRUCTIONS_BY_INTENT.fetch(intent)

    Pjord.respond(message: message, context: context, instructions: instructions)
  rescue StandardError => e
    Rails.logger.error("[PjordReportCommentJob] respond failed: #{e.class}: #{e.message}")
    raise
  end

  def build_message(report)
    <<~MESSAGE
      以下の日報へのコメントを書いてください。

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
