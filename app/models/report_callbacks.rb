# frozen_string_literal: true

class ReportCallbacks
  def after_create(report)
    send_notification(report)
  end

  private
    def send_notification(report)
      if report.user.reports.count == 1
        reciever_list = User.where(retired_on: nil)
        reciever_list.each do |reciever|
          if report.sender != reciever
            Notification.first_report(report, reciever)
          end
        end
      end

      if report.user.trainee?
        receiver_list = User.where(company: report.user.company).where(adviser: true)
        receiver_list.each do |receiver|
          Notification.trainee_report(report, receiver)
        end
      end
    end
end
