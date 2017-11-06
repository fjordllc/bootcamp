class Answer < ActiveRecord::Base
  belongs_to :user
  belongs_to :question
  validates :description, presence: true
  validates :user, presence: true
end
