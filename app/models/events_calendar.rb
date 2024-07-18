# frozen_string_literal: true

class EventsCalendar
  def initialize(user)
    @user = user
  end

  def fetch_events
    upcoming_special_events = Event.fetch_events(@user)

    participated_regular_events = RegularEvent.fetch_participated_regular_events(@user)

    upcoming_special_events + participated_regular_events
  end
end
