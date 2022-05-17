# frozen_string_literal: true

class RegularEventCallbacks
  def after_create(regular_event)
    create_author_watch(regular_event)
  end

  private

  def create_author_watch(regular_event)
    Watch.create!(user: regular_event.user, watchable: regular_event)
  end
end
