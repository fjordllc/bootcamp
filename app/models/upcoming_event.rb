# frozen_string_literal: true

class UpcomingEvent
  attr_reader :original_event, :title, :scheduled_date

  delegate :participants, to: :original_event

  def initialize(event)
    @original_event = event
    @title = event.title
    @scheduled_date = EventSchedule.load(event).tentative_next_event_date
    @event_type = event.class
  end

  class << self
    def wrap(event)
      new(event)
    end
  end

  def held?(date)
    !HolidayJp.holiday?(date) || held_on_national_holiday?
  end

  def for_job_hunting?
    return false if @event_type == RegularEvent

    original_event.job_hunting?
  end

  def ==(other)
    self.class == other.class &&
      %i[original_event title scheduled_date].all? { |attr| public_send(attr) == other.public_send(attr) }
  end

  private

  def held_on_national_holiday?
    return true if @event_type == Event

    original_event.hold_national_holiday
  end
end
