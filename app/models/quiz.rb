# frozen_string_literal: true

class Quiz < ApplicationRecord
  has_many :statements, dependent: :destroy
  has_many :quiz_results, dependent: :destroy

  accepts_nested_attributes_for :statements, allow_destroy: true

  validates :title, presence: true, length: { maximum: 100 }
end
