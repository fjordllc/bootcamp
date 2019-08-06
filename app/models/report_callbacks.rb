# frozen_string_literal: true

class ReportCallbacks
  def after_create(report)
    if report.user.reports.count == 1
      send_notification(
        report: report,
        recievers: User.where(retired_on: nil).where.not(id: report.sender.id),
        message: "#{report.user.login_name}さんがはじめての日報を書きました！"
      )
    end

    if report.user.trainee?
      send_notification(
        report: report,
        recievers: report.user.company.advisers,
        message: "#{report.user.login_name}さんが日報【 #{report.title} 】を書きました！"
      )
    end
  end

  private
    def send_notification(report:, recievers:, message:)
      recievers.each do |reciever|
        Notification.report_submitted(report, reciever, message)
      end
    end
end
