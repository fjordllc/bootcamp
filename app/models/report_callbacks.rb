# frozen_string_literal: true

class ReportCallbacks
  def after_save(report)
    update_published_at(report) if report.first_public?
  end

  def after_create(report)
    create_author_watch(report)
    send_first_report_notification(report) if report.first? && report.first_public?
    notify_to_company_adivisers(report) if report.user.trainee? && report.user.company_id?
    notify_to_followers(report)

    Cache.delete_unchecked_report_count
  end

  def after_update(report)
    send_first_report_notification(report) if report.first? && report.first_public?
    Cache.delete_unchecked_report_count
  end

  def after_destroy(report)
    Cache.delete_unchecked_report_count
    delete_notification(report)
  end

  private

  def create_author_watch(report)
    Watch.create!(user: report.user, watchable: report)
  end

  def send_first_report_notification(report)
    receiver_list = User.where(retired_on: nil)
    receiver_list.each do |receiver|
      NotificationFacade.first_report(report, receiver) if report.sender != receiver
    end
  end

  def create_advisers_watch(report, adviser)
    Watch.create!(user: adviser, watchable: report)
  end

  def create_following_watch(report, follower)
    Watch.create!(user: follower, watchable: report)
  end

  def delete_notification(report)
    Notification.where(path: "/reports/#{report.id}").destroy_all
  end

  def update_published_at(report)
    report.update!(published_at: Time.current)
  end

  def notify_to_followers(report)
    report.user.followers.each do |follower|
      NotificationFacade.following_report(report, follower)
      create_following_watch(report, follower)
    end
  end

  def notify_to_company_adivisers(report)
    report.user.company.advisers.each do |adviser|
      NotificationFacade.trainee_report(report, adviser)
      create_advisers_watch(report, adviser)
    end
  end
end
