class ProductTemplate < ApplicationRecord
  belongs_to :practice

  validates :description, presence: true
  validates :practice, presence: true
end
