# frozen_string_literal: true

class UpcomingEvent
  attr_reader :original_event, :scheduled_date, :title, :event_type

  delegate :participants, to: :original_event

  def initialize(event, scheduled_date)
    @original_event = event
    @scheduled_date = scheduled_date
    @title = event.title
    @event_type = event.class
  end

  def ==(other)
    other.class == self.class &&
      %i[original_event title].all? { |attr| public_send(attr) == other.public_send(attr) }
  end

  def held_on_scheduled_date?
    return true if @event_type == Event

    !HolidayJp.holiday?(@scheduled_date) || held_on_national_holiday?
  end

  def scheduled_date_with_start_time
    return @original_event.start_at if @event_type == Event

    hour = @original_event.start_at.hour
    min = @original_event.start_at.min
    @scheduled_date.in_time_zone.change(hour:, min:)
  end

  def for_job_hunting?
    return false if @event_type == RegularEvent

    original_event.job_hunting?
  end

  private

  def held_on_national_holiday?
    return true if @event_type == Event

    original_event.hold_national_holiday
  end

  class << self
    def build_group(date_key)
      date = date_key_to_date_class(date_key)
      Rails.logger.debug("build_group date: #{date}")
      upcoming_events = original_events_scheduled_on(date).map { |e| UpcomingEvent.new(e, date) }

      UpcomingEventsGroup.new(date_key, upcoming_events.sort_by(&:scheduled_date_with_start_time))
    end

    def upcoming_events_groups
      %i[today tomorrow day_after_tomorrow].map { |key| build_group(key) }
    end

    def fetch(user)
      participated_ids = Event.fetch_participated_ids(user)
      upcoming_ids = Event.fetch_upcoming_ids

      participated_events = Event.where(id: participated_ids & upcoming_ids)
      non_participated_events = Event.where(id: upcoming_ids - participated_ids)

      formatted_participated_events =
        participated_events.each do |participated_event|
          participated_event.title = "【参加登録済】#{participated_event.title}"
        end

      formatted_participated_events + non_participated_events
    end

    private

    def date_key_to_date_class(date_key)
      table = {
        today: Time.zone.today,
        tomorrow: Time.zone.today + 1.day,
        day_after_tomorrow: Time.zone.today + 2.days
      }

      table[date_key.to_sym]
    end

    def original_events_scheduled_on(date)
      [Event, RegularEvent].map do |model|
        model.public_send(:scheduled_on, date)
      end.flatten
    end
  end
end
