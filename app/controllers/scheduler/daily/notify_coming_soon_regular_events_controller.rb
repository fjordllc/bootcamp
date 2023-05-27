# frozen_string_literal: true

class Scheduler::Daily::NotifyComingSoonRegularEventsController < SchedulerController
  def show
    notify_coming_soon_regular_events
    head :ok
  end

  private

  def notify_coming_soon_regular_events
    today_events = RegularEvent.today_events
    tomorrow_events = RegularEvent.tomorrow_events
    return if today_events.blank? && tomorrow_events.blank?

    NotificationFacade.coming_soon_regular_events(today_events, tomorrow_events)
  end
end
