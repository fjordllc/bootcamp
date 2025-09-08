# frozen_string_literal: true

class CorrectAnswer < Answer
  belongs_to :question

  include SearchHelper

  validates :question, uniqueness: true
end
