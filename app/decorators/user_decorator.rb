module UserDecorator
  def part
    weeks = ((Time.now.beginning_of_week - created_at.beginning_of_week) / 60 / 60 / 24 / 7).to_i
    weeks.even? ? 'learning_week' : 'working_week'
  end
end
