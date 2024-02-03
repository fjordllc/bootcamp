# frozen_string_literal: true

class EventOrganizerWatcher
  def call(payload)
    event = payload[:event]
    Watch.create!(user: event.user, watchable: event)
  end
end
