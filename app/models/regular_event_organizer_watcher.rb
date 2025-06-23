# frozen_string_literal: true

class RegularEventOrganizerWatcher
  def call(_name, _started, _finished, _unique_id, payload)
    regular_event = payload[:regular_event]
    Watch.create!(user: regular_event.user, watchable: regular_event)
  end
end
