# frozen_string_literal: true

module EventDateValidations
  extend ActiveSupport::Concern

  private

  def end_at_be_greater_than_start_at
    diff = end_at - start_at
    return unless diff <= 0

    errors.add(:end_at, ': イベント終了日時はイベント開始日時よりも後の日時にしてください。')
  end

  def open_end_at_be_greater_than_open_start_at
    diff = open_end_at - open_start_at
    return unless diff <= 0

    errors.add(:open_end_at, ': 募集終了日時は募集開始日時よりも後の日時にしてください。')
  end

  def open_start_at_be_less_than_start_at
    diff = start_at - open_start_at
    return unless diff <= 0

    errors.add(:open_start_at, ': 募集開始日時はイベント開始日時よりも前の日時にしてください。')
  end

  def open_end_at_be_less_than_end_at
    diff = end_at - open_end_at
    return unless diff.negative?

    errors.add(:open_end_at, ': 募集終了日時はイベント終了日時よりも前の日時にしてください。')
  end
end
