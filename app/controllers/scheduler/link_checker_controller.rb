# frozen_string_literal: true

class Scheduler::LinkCheckerController < SchedulerController
  def update
    LinkChecker::Checker.start
    head :ok
  end
end
