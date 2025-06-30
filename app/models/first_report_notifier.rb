# frozen_string_literal: true

class FirstReportNotifier
  def call(_name, _started, _finished, _unique_id, payload)
    report = payload[:report]
    return if report.wip || !report.first? || Notification.find_by(kind: :first_report, sender_id: report.user.id).present?

    notify_admins_and_mentors(report)
    notify_to_chat(report)
  end

  private

  def notify_admins_and_mentors(report)
    User.admins_and_mentors.each do |receiver|
      ActivityDelivery.with(report:, receiver:).notify(:first_report) if report.sender != receiver
    end
  end

  def notify_to_chat(report)
    DiscordNotifier.with(report:).first_report.notify_now
  end
end
