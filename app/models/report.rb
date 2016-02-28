class Report < ActiveRecord::Base
  has_many :comments
  belongs_to :user

  validates :title, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :description, presence: true
  validates :user, presence: true
end
