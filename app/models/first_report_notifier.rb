# frozen_string_literal: true

class FirstReportNotifier
  def call(report)
    return if report.wip || !report.first? || Notification.find_by(kind: :first_report, sender_id: report.user.id).present?

    User.admins_and_mentors.each do |receiver|
      ActivityDelivery.with(report: report, receiver: receiver).notify(:first_report)
    end
  end
end
