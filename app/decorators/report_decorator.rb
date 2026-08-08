# frozen_string_literal: true

module ReportDecorator
  def number
    serial_number = ReportOrder.new(self).serial_number
    serial_number == 1 ? '初日報' : serial_number
  end
end
