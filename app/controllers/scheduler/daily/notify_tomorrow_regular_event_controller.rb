# frozen_string_literal: true

class Scheduler::Daily::NotifyTomorrowRegularEventController < SchedulerController
  def show
    notify_tomorrow_regular_event
    head :ok
  end

  private

  def notify_tomorrow_regular_event
    return if RegularEvent.tomorrow_events.blank?

    RegularEvent.tomorrow_events.each do |regular_event|
      NotificationFacade.tomorrow_regular_event(regular_event)
    end
  end
end
