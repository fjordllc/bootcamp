# frozen_string_literal: true

class Category < ApplicationRecord
  has_and_belongs_to_many :courses, dependent: :destroy
  has_and_belongs_to_many :practices, dependent: :destroy
  validates :name, presence: true
  validates :slug, presence: true
  acts_as_list
end
