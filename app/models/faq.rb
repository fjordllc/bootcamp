# frozen_string_literal: true

class FAQ < ApplicationRecord
  validates :answer, presence: true, uniqueness: { scope: :question }
  validates :question, presence: true, uniqueness: true

  scope :default_order, -> { order(created_at: :asc) }
end
