# frozen_string_literal: true

class Course < ApplicationRecord
  has_and_belongs_to_many :categories, dependent: :destroy # rubocop:disable Rails/HasAndBelongsToMany
  has_many :practices, through: :categories
  has_many :learnings, through: :practices
  has_many :users, dependent: :nullify
  validates :title, presence: true
  validates :description, presence: true
end
