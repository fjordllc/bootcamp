# frozen_string_literal: true

class Question < ActiveRecord::Base
  belongs_to :user, touch: true
  has_many :answers
  has_one :correct_answer
  belongs_to :practice, optional: true

  validates :title, presence: true, length: { maximum: 256 }
  validates :description, presence: true
  validates :user, presence: true
end
