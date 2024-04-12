# frozen_string_literal: true

class RegularEventCustomHoliday < ApplicationRecord
  belongs_to :regular_event

  validates :holiday_date, presence: true
end
