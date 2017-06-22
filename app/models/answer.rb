class Answer < ActiveRecord::Base
  has_one :question, foreign_key: :correct_answer_id
  belongs_to :user
  belongs_to :question
  validates :description, presence: true
  validates :user, presence: true
end
