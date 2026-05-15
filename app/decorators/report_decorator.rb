# frozen_string_literal: true

module ReportDecorator
  def number
    serial_number == 1 ? '初日報' : serial_number
  end
end
