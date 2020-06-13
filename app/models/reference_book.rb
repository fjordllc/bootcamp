class ReferenceBook < ApplicationRecord
  validates :title, presence: true
  validates :asin, presence: true
  belongs_to :practice
end
