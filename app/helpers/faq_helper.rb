# frozen_string_literal: true

module FaqHelper
  def format_question(question)
    "#{question.delete('?？')}？"
  end
end
