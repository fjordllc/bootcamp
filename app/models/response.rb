# frozen_string_literal: true

class Response < ApplicationRecord
  belongs_to :quiz_result
  belongs_to :statement

  def correct?
    answer == statement.is_correct
  end
end
