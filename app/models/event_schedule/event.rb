# frozen_string_literal: true

module EventSchedule
  class Event
    def initialize(event)
      @event = event
    end

    def tentative_next_event_date
      @event.start_at
    end

    alias held_next_event_date tentative_next_event_date
  end
end
