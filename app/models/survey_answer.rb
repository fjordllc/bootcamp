class SurveyAnswer < ApplicationRecord
  belongs_to :survey
  belongs_to :user
  has_many :survey_question_answers, dependent: :destroy

  validates :survey_id, uniqueness: { scope: :user_id, message: 'すでに回答済みです' }
end
