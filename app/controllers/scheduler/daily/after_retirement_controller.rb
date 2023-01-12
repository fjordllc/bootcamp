# frozen_string_literal: true

class Scheduler::Daily::AfterRetirementController < SchedulerController
  def show
    notify_certain_period_passed
    head :ok
  end

  private

  def notify_certain_period_passed
    admin_users = User.admins
    User.retired_with_3_months_ago_and_notification_not_sent.find_each do |retired_user|
      admin_users.each do |admin_user|
        NotificationFacade.three_months_after_retirement(retired_user, admin_user)
        retired_user.update!(notified_retirement: true)
      end
    end
  end
end
