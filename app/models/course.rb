# frozen_string_literal: true

class Course < ApplicationRecord
  RAILS_COURSE = 'Railsエンジニア'
  DEFAULT_COURSE = RAILS_COURSE

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

  def self.rails_course
    find_by(title: RAILS_COURSE)
  end
end
