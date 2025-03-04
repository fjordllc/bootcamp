# frozen_string_literal: true

class Survey < ApplicationRecord
  belongs_to :user
  has_many :survey_question_listings, dependent: :destroy
  has_many :survey_questions, through: :survey_question_listings
  has_many :survey_answers, dependent: :destroy
  accepts_nested_attributes_for :survey_question_listings, allow_destroy: true
  validates_associated :survey_question_listings

  validates :title, presence: true, length: { maximum: 255 }
  validates :start_at, presence: true
  validates :end_at, presence: true
  validates :survey_question_listings, presence: true

  def before_start?
    Time.current < start_at
  end

  def answer_accepting?
    Time.current.between?(start_at, end_at)
  end

  def answer_ended?
    Time.current > end_at
  end

  def has_answers?
    survey_answers.exists?
  end
end
