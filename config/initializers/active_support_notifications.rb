# frozen_string_literal: true

Rails.application.reloader.to_prepare do
  ActiveSupport::Notifications.subscribe('answer.create', AnswererWatcher.new)
  ActiveSupport::Notifications.subscribe('report.create', FirstReportNotifier.new)
  ActiveSupport::Notifications.subscribe('report.update', FirstReportNotifier.new)
  ActiveSupport::Notifications.subscribe('announcement.create', AnnouncementNotifier.new)
  ActiveSupport::Notifications.subscribe('announcement.update', AnnouncementNotifier.new)
end
