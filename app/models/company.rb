# frozen_string_literal: true

class Company < ApplicationRecord
  validates :name, presence: true
  has_one_attached :logo
end
