# frozen_string_literal: true

class EventsCalendar
  def initialize(user)
    @user = user
  end

  def fetch_events
    special_event = Event.new
    upcoming_speial_events = special_event.fetch_special_events(@user)

    regular_event = RegularEvent.new
    participated_regular_events = regular_event.fetch_participated_regular_events(@user)

    upcoming_speial_events + participated_regular_events
  end
end
