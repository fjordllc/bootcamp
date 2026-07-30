# frozen_string_literal: true

class Pjord::ReportCommentAgent < Pjord::Agent
  inputs :report, :intent
  model ENV.fetch('PJORD_COMMENT_LLM_MODEL', 'claude-opus-5')
  instructions { Pjord::Agent.prompt_for('report_comment', Pjord::ReportCommentAgent.context_for(report, intent)) }

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

  def self.context_for(report, intent)
    sections = ["## 現在の日報分類\n#{intent}"]
    practices = report.practices.map(&:title).join(', ')
    sections << "## 関連プラクティス\n#{practices}" if practices.present?
    sections << "## 日報を書いたユーザー\nログイン名: #{report.user.login_name}"
    sections.join("\n\n")
  end
end
