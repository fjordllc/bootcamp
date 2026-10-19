# frozen_string_literal: true

class Scheduler::StatisticController < SchedulerController
  def show
    SaveLearningMinuteStatistics.call
    head :ok
  end
end
