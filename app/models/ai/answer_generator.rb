# frozen_string_literal: true

module Ai
  class AnswerGenerator
    PRECONDITION = <<~COND
      私はプログラミングスクールの生徒でプログラミングの学習中です。
      あなたはプログラミングスクールの先生です。
      質問に対して優しく、わかりやすく答えてください。
      質問に必要な情報が足りない場合はその点についても指摘してください。
      回答はmarkdown形式で記述してください。
    COND

    TEMPERATURE = 0.7

    DEFAULT_TEXT = '仮の解答です。'

    def initialize(open_ai_access_token:)
      @open_ai_access_token = open_ai_access_token
    end

    def call(question_text)
      return DEFAULT_TEXT if Rails.env.development?

      client = OpenAI::Client.new(access_token: @open_ai_access_token)
      response = client.chat(
        parameters: {
          model: 'gpt-4',
          messages: [
            { role: 'system', content: PRECONDITION },
            { role: 'user', content: question_text }
          ],
          temperature: TEMPERATURE
        }
      )
      response.dig('choices', 0, 'message', 'content')
    end
  end
end
