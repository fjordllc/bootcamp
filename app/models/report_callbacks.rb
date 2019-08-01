# frozen_string_literal: true

class ReportCallbacks
  def after_create(report)
    send_first_report_notification(report) if report.user.reports.count == 1
    send_trainee_report_notification(report) if report.user.trainee?
  end

  private
    def send_first_report_notification(report)
      recievers = User.where(retired_on: nil).where.not(id: report.sender.id)
      recievers.each do |reciever|
        Notification.first_report(report, reciever)
      end
    end

    def send_trainee_report_notification(report)
      receivers = User.advisers.where(company: report.user.company)
      receivers.each do |receiver|
        Notification.trainee_report(report, receiver)
      end
    end
end
