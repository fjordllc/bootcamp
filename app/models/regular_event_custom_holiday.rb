# frozen_string_literal: true

class RegularEventCustomHoliday < ApplicationRecord
  belongs_to :regular_event

  validates :holiday_date, presence: true
  validate :validate_future_date
  validate :check_custom_holidays_against_national_holidays

  private

  def validate_future_date
    return if holiday_date.blank? || holiday_date >= Time.zone.today

    errors.add(:holiday_date, 'は今日以降の日付を入力してください')
  end

  def check_custom_holidays_against_national_holidays
    return if regular_event.hold_national_holiday || !HolidayJp.holiday?(holiday_date)

    formatted_date = I18n.l(holiday_date, format: :default)
    errors.add(:holiday_date, "に設定した#{formatted_date} は祝日です。このイベントは祝日に開催されません。")
  end
end
