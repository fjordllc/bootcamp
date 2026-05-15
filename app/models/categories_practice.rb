# frozen_string_literal: true

class CategoriesPractice < ApplicationRecord
  default_scope -> { order(:position) }
  belongs_to :category
  belongs_to :practice
  acts_as_list scope: :category
end
