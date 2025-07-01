# frozen_string_literal: true

Rails.application.reloader.to_prepare do
  ActiveSupport::Notifications.subscribe('answer.create', AnswererWatcher.new)
  ActiveSupport::Notifications.subscribe('answer.create', AnswerNotifier.new)
  ActiveSupport::Notifications.subscribe('answer.create', NotifierToWatchingUser.new)
  ActiveSupport::Notifications.subscribe('event.create', EventOrganizerWatcher.new)
  ActiveSupport::Notifications.subscribe('regular_event.create', RegularEventOrganizerWatcher.new)
  ActiveSupport::Notifications.subscribe('report.create', FirstReportNotifier.new)
  ActiveSupport::Notifications.subscribe('report.update', FirstReportNotifier.new)
  ActiveSupport::Notifications.subscribe('announcement.create', AnnouncementNotifier.new)
  ActiveSupport::Notifications.subscribe('announcement.update', AnnouncementNotifier.new)
end
