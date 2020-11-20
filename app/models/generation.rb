# frozen_string_literal: true

class Generation
  attr_reader :number

  def initialize(number)
    @number = number
  end

  def start_date
    y = (@number - 1) / 4
    m = @number - y * 4
    year = y + 2013
    month = m * 3 - 2
    Date.new(year, month, 1)
  end

  def end_date
    next_generation = Generation.new(@number + 1)
    next_generation.start_date - 1
  end

  def users
    User.with_attached_avatar.same_generations(start_date, end_date)
  end
end
