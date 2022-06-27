Rails.configuration.to_prepare do
  Newspaper.subscribe(:event_create, EventOrganizerWatcher.new)

  sad_streak_updater = SadStreakUpdater.new
  Newspaper.subscribe(:report_create, sad_streak_updater)
  Newspaper.subscribe(:report_update, sad_streak_updater)
  Newspaper.subscribe(:report_destroy, sad_streak_updater)
end
