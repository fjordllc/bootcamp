# frozen_string_literal: true

class Generation
  def self.start_date(generation)
    y = (generation - 1) / 4
    m = generation - y * 4
    year = y + 2013
    month = m * 3 - 2
    Date.new(year, month, 1)
  end
end
