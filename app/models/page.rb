# frozen_string_literal: true

class Page < ActiveRecord::Base
  include Searchable

  validates :title, presence: true
  validates :body, presence: true
  paginates_per 20

  target_column_of_keyword :title, :body
end
