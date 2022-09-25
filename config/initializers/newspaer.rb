Rails.configuration.to_prepare do
  Newspaper.subscribe(:event_create, EventOrganizerWatcher.new)
  Newspaper.subscribe(:answer_create, AnswerNotifier.new)
<<<<<<< HEAD
  Newspaper.subscribe(:answer_create, NotifierToWatchingUser.new)
  Newspaper.subscribe(:announce_destroy, AnnouncementNotificationDestroyer.new)
=======
  Newspaper.subscribe(:announcement_destroy, AnnouncementNotificationDestroyer.new)
>>>>>>> 引数名をモデル名に合わせるため変更

  sad_streak_updater = SadStreakUpdater.new
  Newspaper.subscribe(:report_create, sad_streak_updater)
  Newspaper.subscribe(:report_update, sad_streak_updater)
  Newspaper.subscribe(:report_destroy, sad_streak_updater)

  learning_cache_destroyer = LearningCacheDestroyer.new
  Newspaper.subscribe(:learning_create, learning_cache_destroyer)
  Newspaper.subscribe(:learning_destroy, learning_cache_destroyer)
end
