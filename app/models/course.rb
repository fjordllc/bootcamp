# frozen_string_literal: true

class Course < ApplicationRecord
  DEFAULT_COURSE = 'Railsエンジニア'

  has_many :courses_categories, dependent: :destroy
  has_many :categories, through: :courses_categories
  has_many :practices, through: :categories
  has_many :learnings, through: :practices
  has_many :users, dependent: :nullify
  validates :title, presence: true
  validates :description, presence: true

  def self.default_course
    find_by(title: DEFAULT_COURSE)
  end

  def extract_practices
    categories = Category
                 .joins(:courses_categories)
                 .where(courses_categories: { course_id: id })
                 .includes(:practices)
                 .order('courses_categories.position')

    categories.map(&:practices).flatten
  end
end
