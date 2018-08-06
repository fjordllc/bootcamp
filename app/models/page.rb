class Page < ActiveRecord::Base
  validates :title, presence: true
  validates :body, presence: true
  paginates_per 20
end
