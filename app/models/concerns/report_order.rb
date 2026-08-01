# frozen_string_literal: true

module ReportOrder
  extend ActiveSupport::Concern

  def previous
    Report.where(user:)
          .where('reported_on < ?', reported_on)
          .order(reported_on: :desc)
          .first
  end

  def next
    Report.where(user:)
          .where('reported_on > ?', reported_on)
          .order(:reported_on)
          .first
  end

  def first?
    serial_number == 1
  end

  def serial_number
    Report.select(:id)
          .where(user:)
          .order(:created_at)
          .index(self) + 1
  end
end
