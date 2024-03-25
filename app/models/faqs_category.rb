# frozen_string_literal: true

class FaqsCategory < ApplicationRecord
  has_many :faqs, dependent: :destroy
end
