# frozen_string_literal: true

class Generation
  START_YEAR = 2013

  class << self
    def generations
      (1..latest_generation_number).map { |n| Generation.new(n) }
    end

    def latest_generation_number
      now_time = Time.zone.now
      (now_time.year - START_YEAR) * 4 + (now_time.month + 2) / 3
    end
  end

  attr_reader :number

  def initialize(number)
    @number = number
  end

  def start_of_fisrt_day
    add_year = (@number - 1) / 4
    year = add_year + START_YEAR
    quarter = @number - add_year * 4
    first_month = quarter * 3 - 2
    Time.zone.local(year, first_month, 1)
  end

  def last_of_end_day
    next_generation = Generation.new(@number + 1)
    end_date = next_generation.start_of_fisrt_day - 1
    end_date.end_of_day
  end

  def users
    User.with_attached_avatar.same_generations(start_of_fisrt_day, last_of_end_day)
  end
end
