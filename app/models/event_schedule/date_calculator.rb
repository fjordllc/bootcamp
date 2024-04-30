# frozen_string_literal: true

module EventSchedule
  module DateCalculator
    def self.calc_what_weeks_in_month(date)
      (date.day + 6) / 7
    end
  end
end
