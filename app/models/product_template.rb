# frozen_string_literal: true

class ProductTemplate < ApplicationRecord
  belongs_to :practice

  validates :description, presence: true
end
