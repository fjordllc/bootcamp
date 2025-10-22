# frozen_string_literal: true

class Scheduler::Daily::AutoRetireController < SchedulerController
  def show
    auto_retire
    head :ok
  end

  private

  def auto_retire
    User.unretired.hibernated_for(User::HIBERNATION_LIMIT).auto_retire.each do |user|
      Retirement.auto(user:).execute
    end
  end
end
