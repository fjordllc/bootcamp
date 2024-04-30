# frozen_string_literal: true

module EventSchedule
  def self.load(event)
    type = event.is_a?(Event) ? 'SpecialEvent' : event.class
    klass = "EventSchedule::#{type}Schedule".constantize
    klass.new(event)
  end
end
