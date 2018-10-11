# frozen_string_literal: true

class Category < ActiveRecord::Base
  has_many :practices, -> { order(:position) }
  validates :name, presence: true
  validates :slug, presence: true
  acts_as_list
end
