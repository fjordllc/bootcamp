# frozen_string_literal: true

class AnnouncementCallbacks
  def after_create(announce)
    return if announce.wip?

    after_first_publish(announce)
    create_author_watch(announce)
  end

  def after_update(announce)
    return unless !announce.wip && announce.published_at.nil?

    after_first_publish(announce)
  end

  private

  def after_first_publish(announce)
    announce.update(published_at: Time.current)
  end

  def create_author_watch(announce)
    Watch.create!(user: announce.user, watchable: announce)
  end
end
