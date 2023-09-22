# frozen_string_literal: true

class NotificationFacade
  def self.trainee_report(report, receiver)
    ActivityNotifier.with(report: report, receiver: receiver).trainee_report.notify_now
    return unless receiver.mail_notification? && !receiver.retired?

    NotificationMailer.with(
      report: report,
      receiver: receiver
    ).trainee_report.deliver_later(wait: 5)
  end

  def self.coming_soon_regular_events(today_events, tomorrow_events)
    DiscordNotifier.with(today_events: today_events, tomorrow_events: tomorrow_events).coming_soon_regular_events.notify_now
  end
end
