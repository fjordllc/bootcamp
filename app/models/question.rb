class Question < ActiveRecord::Base
  belongs_to :user
  belongs_to :correct_answer, foreign_key: :correct_answer_id, class_name: "Answer"
  has_many :answers

  validates :title, presence: true, length: { maximum: 256 }
  validates :description, presence: true
  validates :user, presence: true
  scope :solved, -> { where.not(correct_answer_id: nil) }
  scope :unsolved, -> { where(correct_answer_id: nil) }
end
