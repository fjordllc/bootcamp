# frozen_string_literal: true

class UpcomingEventsGroup
  attr_reader :date_key, :events

  def initialize(date_key, upcoming_events)
    @date_key = date_key
    @events = upcoming_events
  end
end
