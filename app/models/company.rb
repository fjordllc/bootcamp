# frozen_string_literal: true

class Company < ActiveRecord::Base
  validates :name, presence: true
  has_one_attached :logo
end
