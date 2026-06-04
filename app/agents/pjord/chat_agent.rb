# frozen_string_literal: true

class Pjord::ChatAgent < Pjord::Agent
  RECENT_MESSAGES_LIMIT = 10
  PROMPT_TEXT_LIMIT = 2_000

  instructions

  class << self
    def reply(user:, message:, recent_messages: [])
      extract_public_response_body(new(inputs: { user: }).ask(prompt(user:, message:, recent_messages:)).content).presence
    end

    private

    def prompt(user:, message:, recent_messages:)
      <<~TEXT
        受講生からの相談チャットに回答してください。

        ## 相談者
        #{UserInfoTool.new.execute(login_name: user.login_name)}

        ## 直近の相談履歴
        #{format_recent_messages(recent_messages)}

        ## 今回の相談
        #{truncate_for_prompt(message)}
      TEXT
    end

    def format_recent_messages(messages)
      messages.last(RECENT_MESSAGES_LIMIT).map do |chat_message|
        "#{role_label(chat_message.role)}: #{truncate_for_prompt(chat_message.body)}"
      end.join("\n").presence || 'なし'
    end

    def role_label(role)
      role == 'assistant' ? 'ピヨルド' : '相談者'
    end

    def truncate_for_prompt(text)
      text.to_s.slice(0, PROMPT_TEXT_LIMIT)
    end
  end
end
