# frozen_string_literal: true

class Category < ApplicationRecord
  has_and_belongs_to_many :courses, dependent: :destroy # rubocop:disable Rails/HasAndBelongsToMany
  has_many :categories_practices, dependent: :destroy
  has_many :practices, through: :categories_practices
  validates :name, presence: true
  validates :slug, presence: true
  acts_as_list

  def self.category(practice:, course:)
    categories = practice.categories
    my_categories = categories.where(id: course.category_ids)

    if categories.size.positive?
      my_categories.first
    else
      categories.first
    end
  end
end
