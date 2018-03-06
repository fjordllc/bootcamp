class Report < ActiveRecord::Base
  has_many :comments
  has_many :checks
  has_many :footprints
  has_and_belongs_to_many :practices
  belongs_to :user, touch: true

  validates :title, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :description, presence: true
  validates :user, presence: true
  validates :reported_at, presence: true, uniqueness: { scope: :user }
end
