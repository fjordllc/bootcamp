# frozen_string_literal: true

class Page < ActiveRecord::Base
  include Searchable

  validates :title, presence: true
  validates :body, presence: true
  paginates_per 20

  columns_for_keyword_search :title, :body
end
