# frozen_string_literal: true

class Scheduler::Daily::AutoRetireController < SchedulerController
  def show
    auto_retire
    head :ok
  end

  private

  def auto_retire
    User.unretired.hibernated_for(User::HIBERNATION_LIMIT).auto_retire.each do |user|
      user.retire_reason = '（休会後三ヶ月経過したため自動退会）'
      user.retired_on = Date.current
      user.hibernated_at = nil
      user.save!(validate: false)

      AfterUserRetirement.new(user, triggered_by: 'hibernation').call
    end
  end
end
