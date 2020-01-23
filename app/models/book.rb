# frozen_string_literal: true

class Book < ApplicationRecord
  has_many :borrowings
  has_many :users, through: :borrowings

  validates :title, presence: true
  validates :isbn, presence: true
  validates :borrowed, inclusion: { in: [true, false] }
  paginates_per 20

  def self.search(word)
    Book.ransack(title_cont: word).result
  end
end
