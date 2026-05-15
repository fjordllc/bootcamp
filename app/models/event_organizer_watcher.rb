# frozen_string_literal: true

class EventOrganizerWatcher
  def call(_name, _started, _finished, _unique_id, payload)
    event = payload[:event]
    Watch.create!(user: event.user, watchable: event)
  end
end
