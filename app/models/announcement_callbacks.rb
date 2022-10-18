# frozen_string_literal: true

class AnnouncementCallbacks
  def after_create(announce)
    return if announce.wip?

    create_author_watch(announce)
  end

  private

  def create_author_watch(announce)
    Watch.create!(user: announce.user, watchable: announce)
  end
end
