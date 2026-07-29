# frozen_string_literal: true

class Pjord::QuestionAnswerAgent < Pjord::Agent
  instructions { Pjord::Agent.prompt_for('question_answer', Pjord::QuestionAnswerAgent.context_for(question)) }

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

  def self.context_for(question)
    sections = ["## 現在の場所\n#{question.where_mention}"]
    sections << "## 関連プラクティス\n#{question.practice.title}" if question.practice.present?
    sections.join("\n\n")
  end
end
