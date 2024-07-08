# frozen_string_literal: true

class SubmissionAnswer < ApplicationRecord
  belongs_to :practice
  validates :description, presence: true
end
