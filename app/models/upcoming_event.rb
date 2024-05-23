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

  def held?(date)
    return true if @event_type == Event

    !HolidayJp.holiday?(date) || held_on_national_holiday?
  end

  def date_with_start_time(date)
    return @original_event.start_at if @event_type == Event

    hour = @original_event.start_at.hour
    min = @original_event.start_at.min
    date.in_time_zone.change(hour:, min:)
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
end
