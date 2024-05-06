# frozen_string_literal: true

class FaqsCategory < ApplicationRecord
  validates :name, presence: true, unique: true

  has_many :faqs, dependent: :destroy
end
