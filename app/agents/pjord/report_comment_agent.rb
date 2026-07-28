# frozen_string_literal: true

class Pjord::ReportCommentAgent < Pjord::Agent
  inputs :report, :intent
  model ENV.fetch('PJORD_COMMENT_LLM_MODEL', 'claude-opus-5')
  instructions

  def self.comment(report, intent:)
    extract_public_response_body(new(inputs: { report:, intent: }).ask(message(report)).content).presence
  end

  def self.message(report)
    <<~MESSAGE
      以下の日報へのコメントを書いてください。

      ## 日報タイトル
      #{report.title}

      ## 日報本文
      #{report.description}
    MESSAGE
  end
end
