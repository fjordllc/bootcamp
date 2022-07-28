# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :courses_categories, dependent: :destroy
  has_many :courses, through: :courses_categories
  has_many :categories_practices, dependent: :destroy
  has_many :practices, through: :categories_practices
  validates :name, presence: true
  validates :slug, presence: true

  def self.category(practice:, course:)
    categories = practice.categories
    my_categories = categories.where(id: course.category_ids)

    if my_categories.size.positive?
      my_categories.first
    else
      categories.first
    end
  end
end
