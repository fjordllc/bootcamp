# frozen_string_literal: true

class UpcomingEventsGroup
  EVENT_MODELS = [Event, RegularEvent].freeze

  attr_reader :date_key, :date, :events

  def initialize(date_key, date, upcoming_events)
    @date_key = date_key
    @date = date
    @events = upcoming_events.sort_by { |e| e.date_with_start_time(@date) }
  end

  def ==(other)
    other.class == self.class &&
      %i[date_key date events].all? { |attr| public_send(attr) == other.public_send(attr) }
  end

  class << self
    def build(date_key)
      date = date_key_to_date_class(date_key)

      upcoming_events = original_events_scheduled_on(date).map { |e| UpcomingEvent.new(e) }

      new(date_key, date, upcoming_events)
    end

    private

    def original_events_scheduled_on(date)
      EVENT_MODELS.map do |event_model|
        event_model.public_send(:gather_events_scheduled_on, date)
      end.flatten
    end

    def date_key_to_date_class(date_key)
      table = {
        today: Time.zone.today,
        tomorrow: Time.zone.today + 1.day,
        day_after_tomorrow: Time.zone.today + 2.days
      }

      table[date_key.to_sym]
    end
  end
end
