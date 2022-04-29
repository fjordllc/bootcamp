# frozen_string_literal: true

class EventOrganizerWatcher
  def call(event)
    Watch.create!(user: event.user, watchable: event)
  end
end
