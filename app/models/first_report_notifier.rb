class FirstReportNotifier
  def call(report)
    return if report.wip || !report.first? || Notification.find_by(kind: :first_report, sender_id: report.user.id).present?

    User.admins_and_mentors.each do |receiver|
      NotificationFacade.first_report(report, receiver) if report.sender != receiver
    end
  end
end
