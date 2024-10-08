# frozen_string_literal: true

class FAQCategory < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  has_many :faqs, dependent: :destroy
end
