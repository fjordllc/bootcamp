# frozen_string_literal: true

class UpcomingEvent
  attr_reader :original_event, :title, :scheduled_date

  delegate :participants, to: :original_event

  def initialize(event)
    @original_event = event
    @title = event.title
    @scheduled_date = event.recent_scheduled_date
    @event_type = event.class
  end

  class << self
    def wrap(event)
      new(event)
    end
  end

  def held_on_national_holiday?
    return true if @event_type == Event

    original_event.hold_national_holiday
  end

  def for_job_hunting?
    return false if @event_type == RegularEvent

    original_event.job_hunting?
  end
end
