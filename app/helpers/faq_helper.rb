# frozen_string_literal: true

module FAQHelper
  def format_question(question)
    "#{question.delete('?？')}？"
  end
end
