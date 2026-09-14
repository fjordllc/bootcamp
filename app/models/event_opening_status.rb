# frozen_string_literal: true

class EventOpeningStatus
  def initialize(event)
    @event = event
  end

  def opening?
    Time.current.between?(@event.open_start_at, @event.open_end_at)
  end

  def before_opening?
    Time.current < @event.open_start_at
  end

  def closing?
    Time.current > @event.open_end_at && Time.current < @event.end_at
  end

  def ended?
    Time.current >= @event.end_at
  end
end
