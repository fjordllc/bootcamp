# frozen_string_literal: true

class FaqsCategories < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  has_many :faqs, dependent: :destroy
end
