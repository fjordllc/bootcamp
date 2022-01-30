# frozen_string_literal: true

class Scheduler::LinkCheckerController < SchedulerController
  def show
    checker = LinkChecker::Checker.new
    checker.notify_broken_links
    render plain: checker.errors.join("\n")
  end
end
