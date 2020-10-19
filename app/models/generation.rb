# frozen_string_literal: true

class Generation
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

  def users
    next_generation = Generation.new(@number + 1)
    User.with_attached_avatar.same_generations(start_date, next_generation.start_date)
  end
end
