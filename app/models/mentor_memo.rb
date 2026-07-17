# frozen_string_literal: true

class MentorMemo < ApplicationRecord
  belongs_to :user
  belongs_to :author, class_name: 'User', optional: true

  validates :content, presence: true

end
