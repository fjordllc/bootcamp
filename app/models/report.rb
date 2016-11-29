class Report < ActiveRecord::Base
  has_many :comments
  belongs_to :user
  belongs_to :practice

  validates :title, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :practice_id, presence: true
  validates :description, presence: true
  validates :user, presence: true
end
