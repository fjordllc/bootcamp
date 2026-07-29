# frozen_string_literal: true

class Pjord::Agent < RubyLLM::Agent
  SYSTEM_PROMPT = Rails.root.join('app/prompts/pjord/agent/instructions.txt').read.freeze

  model ENV.fetch('PJORD_LLM_MODEL', 'claude-sonnet-5')
  tools BootcampSearchTool, UserInfoTool, ExternalContentTool
  schema PjordResponse
  instructions { AiPrompt.body_for('pjord') }

  class << self
    def prompt_for(key, context = nil)
      [AiPrompt.body_for('pjord'), AiPrompt.body_for(key), context].compact_blank.join("\n\n")
    end

    def extract_public_response_body(content)
      body =
        if content.is_a?(String)
          parse_response_body(content)
        elsif content.respond_to?(:to_h)
          parsed = content.to_h
          parsed['body'] || parsed[:body] if parsed.is_a?(Hash)
        end

      remove_internal_preamble(body)
    end

    private

    def parse_response_body(content)
      parsed = JSON.parse(content)
      parsed.is_a?(Hash) ? parsed['body'] : content
    rescue JSON::ParserError
      content
    end

    def remove_internal_preamble(body)
      return body unless body.is_a?(String)

      body.sub(/\A\s*(?:検索結果を踏まえて、)?(?:日報へのコメント|回答|コメント)を作成します。\s*/, '')
    end
  end
end
