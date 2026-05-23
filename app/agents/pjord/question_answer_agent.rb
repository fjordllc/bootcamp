# frozen_string_literal: true

class Pjord::QuestionAnswerAgent < Pjord::Agent
  instructions

  def self.answer(question)
    extract_public_response_body(new(inputs: { question: }).ask(message(question)).content).presence
  end

  def self.message(question)
    <<~MESSAGE
      以下のQ&A質問に回答してください。

      ## タイトル
      #{question.title}

      ## 質問内容
      #{question.description}
    MESSAGE
  end
end
