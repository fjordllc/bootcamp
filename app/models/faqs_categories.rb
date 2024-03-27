# frozen_string_literal: true

class FaqsCategories < ApplicationRecord
  has_many :faqs, dependent: :destroy
end
