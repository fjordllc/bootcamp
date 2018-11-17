# frozen_string_literal: true

class Course < ApplicationRecord
  has_and_belongs_to_many :categories, dependent: :destroy
  has_many :practices, through: :categories
  has_many :users
  validates :title, presence: true
  validates :description, presence: true
end
