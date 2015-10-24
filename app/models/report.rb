class Report < ActiveRecord::Base
  belongs_to :user
  validates :title,
    presence: true,
    uniqueness: true,
    length: { maximum: 255 }
  validates :description, presence: true
  validates :user, presence: true
end
