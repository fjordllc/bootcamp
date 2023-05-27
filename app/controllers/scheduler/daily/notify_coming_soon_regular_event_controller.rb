# frozen_string_literal: true

class Scheduler::Daily::NotifyComingSoonRegularEventController < SchedulerController
  def show
    notify_coming_soon_regular_event
    head :ok
  end

  private

  def notify_coming_soon_regular_event
    return puts "通知するイベントがないのでDiscordへの通知は行われません。" if RegularEvent.today_events.blank? && RegularEvent.tomorrow_events.blank?

    NotificationFacade.coming_soon_regular_events
  end
end
