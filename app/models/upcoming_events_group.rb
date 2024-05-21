# frozen_string_literal: true

class UpcomingEventsGroup
  EVENT_MODELS = [Event, RegularEvent].freeze

  DATE_KEY_TO_DATE_CLASS = {
    today: Time.zone.today,
    tomorrow: Time.zone.today + 1.day,
    day_after_tomorrow: Time.zone.today + 2.days
  }.freeze

  attr_reader :date_key, :date, :events

  def initialize(date_key, date, upcoming_events)
    @date_key = date_key
    @date = date
    @events = upcoming_events.sort_by { |e| e.date_with_start_time(@date) }
  end

  def ==(other)
    other.class == self.class &&
      %i[date events].all? { |attr| public_send(attr) == other.public_send(attr) }
  end

  class << self
    def build(date_key)
      date = DATE_KEY_TO_DATE_CLASS[date_key]
      original_events = fetch_scheduled_original_events(date, EVENT_MODELS)
      upcoming_events = original_events.map { |e| UpcomingEvent.new(e) }
      new(date_key, date, upcoming_events)
    end

    private

    def fetch_scheduled_original_events(date, event_models)
      event_models.map do |event_model|
        event_model.public_send(:gather_events_scheduled_on, date)
      end.flatten
    end
  end
end
