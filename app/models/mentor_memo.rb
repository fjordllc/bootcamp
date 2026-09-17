# frozen_string_literal: true

class MentorMemo < ApplicationRecord
  belongs_to :recipient, class_name: 'User'
  belongs_to :writer, class_name: 'User'

  validates :body, presence: true
end
