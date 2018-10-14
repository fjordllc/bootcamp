# frozen_string_literal: true

class Answer < ActiveRecord::Base
  belongs_to :user, touch: true
  belongs_to :question
  validates :description, presence: true
  validates :user, presence: true
end
