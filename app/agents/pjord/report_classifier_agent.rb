# frozen_string_literal: true

class Pjord::ReportClassifierAgent < RubyLLM::Agent
  model ENV.fetch('PJORD_LLM_MODEL', 'claude-sonnet-4-6')
  schema PjordReportIntent
  instructions

  def self.classify(report)
    content = new.ask(message(report)).content
    parsed = parse_content(content)
    return nil unless parsed.is_a?(Hash)

    parsed = parsed.stringify_keys
    intent = parsed['intent']
    return nil unless PjordReportIntent::INTENTS.include?(intent)

    { intent: intent, reason: parsed['reason'] }
  rescue JSON::ParserError => e
    Rails.logger.error("[Pjord::ReportClassifierAgent] JSON parse error: #{e.message}")
    nil
  end

  def self.message(report)
    <<~TEXT
      以下の日報を分類してください。

      ## タイトル
      #{report.title}

      ## 本文
      #{report.description}
    TEXT
  end

  def self.parse_content(content)
    if content.is_a?(String)
      JSON.parse(content)
    elsif content.respond_to?(:to_h)
      content.to_h
    else
      content
    end
  end
end
