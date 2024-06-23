# frozen_string_literal: true

class ModelAnswer < ApplicationRecord
  belongs_to :practice
  validates :description, presence: true
end
