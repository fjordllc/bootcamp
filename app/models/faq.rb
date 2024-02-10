# frozen_string_literal: true

class FAQ < ApplicationRecord
  validates :answer, presence: true, uniqueness: { scope: :question }
  validates :question, presence: true, uniqueness: true

  default_scope -> { order(:position) }
  acts_as_list
end
