# frozen_string_literal: true

Rails.application.reloader.to_prepare do
  ActiveSupport::Notifications.subscribe('answer.create', AnswererWatcher.new)
  ActiveSupport::Notifications.subscribe('answer.create', AnswerNotifier.new)
  ActiveSupport::Notifications.subscribe('answer.create', NotifierToWatchingUser.new)
  ActiveSupport::Notifications.subscribe('event.create', EventOrganizerWatcher.new)
  ActiveSupport::Notifications.subscribe('regular_event.create', RegularEventOrganizerWatcher.new)

  watch_for_pair_work_creator = WatchForPairWorkCreator.new
  ActiveSupport::Notifications.subscribe('pair_work.create', watch_for_pair_work_creator)
  ActiveSupport::Notifications.subscribe('pair_work.update', watch_for_pair_work_creator)

  pair_work_notifier = PairWorkNotifier.new
  ActiveSupport::Notifications.subscribe('pair_work.create', pair_work_notifier)
  ActiveSupport::Notifications.subscribe('pair_work.update', pair_work_notifier)

  ActiveSupport::Notifications.subscribe('pair_work.update', PairWorkMatchingNotifier.new)
end
