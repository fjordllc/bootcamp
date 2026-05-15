# frozen_string_literal: true

class NotificationFacade
  def self.trainee_report(report, receiver)
    notification = ActivityNotifier.with(report:, receiver:).trainee_report.notify_now
    return unless receiver.mail_notification? && !receiver.retired?

    mailer = NotificationMailer.with(report:, receiver:, notification:).trainee_report
    if Rails.env.test?
      mailer.deliver_now
    else
      mailer.deliver_later(wait: 5)
    end
  end

  def self.coming_soon_regular_events(today_events, tomorrow_events)
    DiscordNotifier.with(today_events:, tomorrow_events:).coming_soon_regular_events.notify_now
  end
end
