# frozen_string_literal: true

module ReportDecorator
  def number
    number = serial_number
    number == 1 ? '初日報' : number
  end
end
