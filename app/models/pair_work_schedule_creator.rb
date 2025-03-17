# frozen_string_literal: true

class PairWorkScheduleCreator
  def call(payload)
    pair_work = payload[:pair_work]
    schedules = payload[:schedules]
    schedules.each do |schedule|
      pair_work.schedules.create(proposed_at: schedule)
    end
  end
end
