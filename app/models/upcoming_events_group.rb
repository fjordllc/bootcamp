# frozen_string_literal: true

class UpcomingEventsGroup
  attr_reader :date, :events

  def initialize(date = :today)
    @date = date
    @original_events = fetch_date_events(date, Event, RegularEvent)
    @events = original_events.map { |event| UpcomingEvent.wrap(event) }
  end

  private

  attr_reader :original_events

  def fetch_date_events(date, *event_models)
    fetch_date_events_method = "#{date}_events"

    event_models.map do |event_model|
      event_model.public_send(fetch_date_events_method)
    end.flatten
  end
end
