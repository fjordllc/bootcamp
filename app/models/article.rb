# frozen_string_literal: true

class Article < ApplicationRecord
  validates :title, presence: true
  validates :body, presence: true
  paginates_per 10
end
