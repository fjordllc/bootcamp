# frozen_string_literal: true

Rails.application.reloader.to_prepare do
  ActiveSupport::Notifications.subscribe('answer.create', AnswererWatcher.new)
  ActiveSupport::Notifications.subscribe('answer.create', AnswerNotifier.new)
  ActiveSupport::Notifications.subscribe('answer.create', NotifierToWatchingUser.new)
  ActiveSupport::Notifications.subscribe('event.create', EventOrganizerWatcher.new)
  ActiveSupport::Notifications.subscribe('regular_event.create', RegularEventOrganizerWatcher.new)

  sad_streak_updater = SadStreakUpdater.new
  ActiveSupport::Notifications.subscribe('report.save', sad_streak_updater)
  ActiveSupport::Notifications.subscribe('report.destroy', sad_streak_updater)

  learning_cache_destroyer = LearningCacheDestroyer.new
  ActiveSupport::Notifications.subscribe('learning.create', learning_cache_destroyer)
  ActiveSupport::Notifications.subscribe('learning.destroy', learning_cache_destroyer)
end
