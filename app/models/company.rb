# frozen_string_literal: true

class Company < ActiveRecord::Base
  has_many :users
  validates :name, presence: true
  has_one_attached :logo

  def advisers
    users.advisers
  end
end
