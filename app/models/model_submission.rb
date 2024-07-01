# frozen_string_literal: true

class ModelSubmission < ApplicationRecord
  belongs_to :practice
  validates :description, presence: true
end
