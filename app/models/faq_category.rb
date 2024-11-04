# frozen_string_literal: true

class FAQCategory < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  has_many :faqs, -> { order(:position) }, dependent: :destroy, inverse_of: :faq_category
  default_scope -> { order(:position) }
  acts_as_list
end
