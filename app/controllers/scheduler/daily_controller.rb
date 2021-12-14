# frozen_string_literal: true

class Scheduler::DailyController < SchedulerController
  def show
    User.notify_to_discord
    User.retired.find_each do |retired_user|
      if retired_user.retired_on <= Date.current.prev_month(n = 3)
        User.admins.each do |admin_user|
          Notification.retired_after_three_months(retired_user, admin_user)
          NotificationFacade.retired_after_three_months(retired_user, admin_user)
        end
      end
    end
    head :ok
  end
end
