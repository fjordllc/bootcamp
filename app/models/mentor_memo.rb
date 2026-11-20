# frozen_string_literal: true

class MentorMemo < ApplicationRecord
  belongs_to :user
  belongs_to :author, class_name: 'User', optional: true

  validates :content, presence: true

  scope :oldest_first, -> { order(arel_table[:created_at].asc.nulls_last) }
end
