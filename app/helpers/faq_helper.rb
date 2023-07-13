# frozen_string_literal: true

module FAQHelper
  def format_question(question)
    "#{question.delete('?？')}？"
  end

  def question_mark_with(question)
    "#{question}？"
  end
end
