# frozen_string_literal: true

class UserRegularEventCleanup
  def initialize(user)
    @user = user
  end

  def clean_up_regular_events
    @user.regular_event_participations.for_unfinished_events.destroy_all
    @user.organize_regular_events.exclude_finished.each { |event| event.close_or_destroy_organizer(@user) }
  end
end
