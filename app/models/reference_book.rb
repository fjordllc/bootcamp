# frozen_string_literal: true

class ReferenceBook < ApplicationRecord
  belongs_to :practice
  validates :title, presence: true
end
