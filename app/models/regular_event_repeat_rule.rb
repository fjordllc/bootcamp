# frozen_string_literal: true

class RegularEventRepeatRule < ApplicationRecord
  belongs_to :regular_event

  validates :frequency, presence: true
  validates :day_of_the_week, presence: true
end
