class Practice < ActiveRecord::Base
  has_many :learnings

  validates :title, presence: true
  validates :description, presence: true
end
