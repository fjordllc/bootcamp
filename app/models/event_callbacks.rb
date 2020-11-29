# frozen_string_literal: true

class EventCallbacks
  def after_create(event)
    create_author_watch(event)
  end

  private

  def create_author_watch(event)
    Watch.create!(user: event.user, watchable: event)
  end
end
