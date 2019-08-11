# frozen_string_literal: true

class ReportCallbacks
  def after_create(report)
    if report.user.reports.count == 1
      send_first_report_notification(report)
    end

    if report.user.trainee?
      report.user.company.advisers.each do |adviser|
        send_trainee_report_notification(report, adviser)
        create_advisers_watch(report, adviser)
      end
    end
  end

  private
    def send_first_report_notification(report)
      reciever_list = User.where(retired_on: nil)
      reciever_list.each do |reciever|
        if report.sender != reciever
          Notification.first_report(report, reciever)
        end
      end
    end

    def send_trainee_report_notification(report, reciever)
      Notification.trainee_report(report, reciever)
    end

    def create_advisers_watch(report, adviser)
      Watch.create!(user: adviser, watchable: report)
    end
end
