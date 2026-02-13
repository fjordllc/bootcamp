# frozen_string_literal: true

class MicroReportCallbacks
  def after_destroy(micro_report)
    delete_notifications(micro_report)
  end

  private

  def delete_notifications(micro_report)
    Notification.where(link: micro_report.path).destroy_all
  end
end
