# frozen_string_literal: true

class Scheduler::RetirementNoticeController < SchedulerController
  def show
    User.notify_to_discord
    head :ok
  end
end
