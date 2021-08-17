# frozen_string_literal: true

class Article < ApplicationRecord
  belongs_to :user
  validates :title, presence: true
  validates :body, presence: true
  paginates_per 10
  acts_as_taggable
end
