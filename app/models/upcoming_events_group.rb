# frozen_string_literal: true

class UpcomingEventsGroup
  EVENT_MODELS = [Event, RegularEvent].freeze

  attr_reader :date, :events

  def initialize(date, upcoming_events)
    @date = date
    @events = upcoming_events.sort_by(&:scheduled_date)
  end

  class << self
    def create(date)
      original_events = fetch_dated_original_events(date, EVENT_MODELS)
      upcoming_events = original_events.map { |e| UpcomingEvent.wrap(e) }
      new(date, upcoming_events)
    end

    private

    def fetch_dated_original_events(date, event_models)
      fetch_date_events_method = "#{date}_events"

      event_models.map do |event_model|
        event_model.public_send(fetch_date_events_method)
      end.flatten
    end
  end
end
