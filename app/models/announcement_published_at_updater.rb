# frozen_string_literal: true

class AnnouncementPublishedAtUpdater
  def call(announce)
    return if announce.wip? || announce.published_at.nil?

    announce.update(published_at: Time.current)
  end
end
