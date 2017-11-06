class Question < ActiveRecord::Base
  belongs_to :user
  has_many :answers
  has_one :correct_answer

  validates :title, presence: true, length: { maximum: 256 }
  validates :description, presence: true
  validates :user, presence: true
end
