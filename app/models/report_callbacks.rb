# frozen_string_literal: true

class ReportCallbacks
  def after_create(report)
    create_author_watch(report)
  end

  def after_destroy(report)
    Cache.delete_unchecked_report_count
    Cache.delete_user_unchecked_report_count(report.user_id)
    delete_notification(report)
  end

  private

  def create_author_watch(report)
    Watch.create!(user: report.user, watchable: report)
  end

  def delete_notification(report)
    Notification.where(link: "/reports/#{report.id}").destroy_all
  end
end
