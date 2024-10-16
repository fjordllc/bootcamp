# frozen_string_literal: true

class FAQ < ApplicationRecord
  validates :answer, presence: true, uniqueness: { scope: :question }
  validates :question, presence: true, uniqueness: true
  validates :faq_category_id, presence: true

  default_scope -> { order(:position) }
  belongs_to :faq_category
  acts_as_list
end
