# frozen_string_literal: true

class CorrectAnswer < Answer
  belongs_to :question

  include SearchHelper
end
