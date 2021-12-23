# frozen_string_literal: true

class Scheduler::DailyController < SchedulerController
  def show
    User.notify_to_discord
    User.retired.find_each do |retired_user|
      if retired_user.retired_three_months_ago_and_not_send_notification?(retired_user)
        User.admins.each do |admin_user|
          Notification.three_months_after_retirement(retired_user, admin_user)
          NotificationFacade.three_months_after_retirement(retired_user, admin_user)
          retired_user.update!(retired_notification: true)
        end
      end
    end
    head :ok
  end
end
