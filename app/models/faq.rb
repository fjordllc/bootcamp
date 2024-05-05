# frozen_string_literal: true

class FAQ < ApplicationRecord
  validates :answer, presence: true, uniqueness: { scope: :question }
  validates :question, presence: true, uniqueness: true

  default_scope -> { order(:position) }
  belongs_to :faqs_category, optional: true
  acts_as_list
end
