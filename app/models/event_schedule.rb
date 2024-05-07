# frozen_string_literal: true

module EventSchedule
  def self.load(event)
    klass = "EventSchedule::#{event.class}".constantize
    klass.new(event)
  end
end
