# frozen_string_literal: true

class PiyoChatService
  SECTION_PROMPT = <<~PROMPT
    ## 現在のコンテキスト
    ユーザーは教科書のセクションを読んでいます。
    このセクションの内容に基づいて回答してください。
    回答は簡潔にわかりやすく、セクションの範囲内で説明してください。
    脱線せず、セクションの学習目標に沿った回答を心がけてください。
  PROMPT

  class << self
    def respond(user:, section:, message:)
      chat = RubyLLM.chat(model: model_name)
      chat.with_instructions(build_prompt(section))

      history = recent_history(user, section)
      history.each do |msg|
        chat.ask(msg.content) if msg.role == 'user'
      end

      result = chat.ask(message)
      result.content.presence || 'ごめんなさい、うまく回答できませんでした。メンターに聞いてみてください。'
    rescue StandardError => e
      Rails.logger.error("PiyoChatService error: #{e.message}")
      'ごめんなさい、エラーが発生しました。もう一度試してみてください。'
    end

    private

    def model_name
      ENV.fetch('PJORD_LLM_MODEL', 'gpt-5-mini')
    end

    def build_prompt(section)
      parts = [Pjord::SYSTEM_PROMPT, SECTION_PROMPT]
      parts << textbook_info(section)
      parts << goals_section(section) if section.goals.present? && section.goals.any?(&:present?)
      parts << terms_section(section) if section.key_terms.present? && section.key_terms.any?(&:present?)
      parts.join("\n\n")
    end

    def textbook_info(section)
      "## 教科書情報\n- 教科書: #{section.chapter.textbook.title}\n- 章: #{section.chapter.title}\n- セクション: #{section.title}"
    end

    def goals_section(section)
      "## 学習目標\n#{section.goals.select(&:present?).map { |g| "- #{g}" }.join("\n")}"
    end

    def terms_section(section)
      "## 重要用語\n#{section.key_terms.select(&:present?).join(', ')}"
    end

    def recent_history(user, section)
      PiyoChatMessage.where(user: user, textbook_section_id: section.id)
                     .order(created_at: :asc)
                     .last(10)
    end
  end
end
