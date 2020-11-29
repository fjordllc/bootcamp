# frozen_string_literal: true

class ReportCallbacks
  def after_create(report)
    create_author_watch(report)

    if report.user.reports.count == 1 && !report.wip?
      send_first_report_notification(report)
    end

    if report.user.trainee?
      report.user.company.advisers.each do |adviser|
        NotificationFacade.trainee_report(report, adviser)
        create_advisers_watch(report, adviser)
      end
    end

    report.user.followers.each do |follower|
      NotificationFacade.following_report(report, follower)
      create_following_watch(report, follower)
    end

    Cache.delete_unchecked_report_count
  end

  def after_update(report)
    if report.wip == false && report.user.reports.count == 1
      send_first_report_notification(report)
    end

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
      if report.sender != receiver
        NotificationFacade.first_report(report, receiver)
      end
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
end
