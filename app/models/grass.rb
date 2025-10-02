# frozen_string_literal: true

class Grass
  def self.times(user, end_date)
    GrassLearningTimeQuery.call(user, end_date)
  end
end
