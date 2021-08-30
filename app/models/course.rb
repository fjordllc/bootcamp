# frozen_string_literal: true

class Course < ApplicationRecord
  has_many :courses_categories, dependent: :destroy
  has_many :categories, through: :courses_categories
  has_many :practices, through: :categories
  has_many :learnings, through: :practices
  has_many :users, dependent: :nullify
  validates :title, presence: true
  validates :description, presence: true
end
