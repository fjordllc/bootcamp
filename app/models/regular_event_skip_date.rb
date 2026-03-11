# frozen_string_literal: true

class RegularEventSkipDate < ApplicationRecord
  belongs_to :regular_event
  validates :skip_on, comparison: { greater_than_or_equal_to: -> { Time.zone.today }, message: 'は本日以降の日付を入力してください' }, if: :will_save_change_to_skip_on?

  scope :from_today, -> { where('skip_on >= ?', Time.zone.today) }
end
