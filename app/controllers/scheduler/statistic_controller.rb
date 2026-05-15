# frozen_string_literal: true

class Scheduler::StatisticController < SchedulerController
  def show
    Practice.save_learning_minute_statistics
    head :ok
  end
end
