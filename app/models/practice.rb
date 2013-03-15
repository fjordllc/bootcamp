class Practice < ActiveRecord::Base
  include RankedModel
  ranks :row_order
  has_many :learnings
  validates :title, presence: true
  validates :description, presence: true
end
