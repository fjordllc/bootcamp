# frozen_string_literal: true

class ReportCallbacks
  def after_create(report)
    send_first_report_notification(report) if report.user.reports.count == 1
    send_trainee_report_notification(report) if report.user.trainee?
  end

  private
    def send_first_report_notification(report)
      message = "#{report.user.login_name}さんがはじめての日報を書きました！"
      User.where(retired_on: nil).where.not(id: report.sender.id).each do |reciever|
        Notification.report_submitted(report, reciever, message)
      end
    end

    def send_trainee_report_notification(report)
      message = "#{report.user.login_name}さんが日報【 #{report.title} 】を書きました！"
      User.advisers(report.user.company).each do |receiver|
        Notification.report_submitted(report, receiver, message)
      end
    end
end
