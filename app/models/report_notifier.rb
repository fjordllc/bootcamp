# frozen_string_literal: true

class ReportNotifier
  def call(_name, _started, _finished, _unique_id, payload)
    report = payload[:report]
    Cache.delete_unchecked_report_count

    return unless report.first_public?

    report.update_column(:published_at, report.updated_at) # rubocop:disable Rails/SkipsModelValidations

    notify_users(report)
    notify_to_chat(report)
  end

  private

  def notify_users(report)
    notify_advisers(report) if report.user.trainee? && report.user.company_id?
    notify_consecutive_sad_report(report) if report.user.depressed?
    notify_followers(report)
    report.notify_all_mention_user
  end

  def notify_to_chat(report)
    ChatNotifier.message(<<~TEXT, webhook_url: ENV['DISCORD_REPORT_WEBHOOK_URL'])
      #{report.user.login_name}さんが#{I18n.l report.reported_on}の日報を公開しました。
      タイトル：「#{report.title}」
      URL： <https://bootcamp.fjord.jp/reports/#{report.id}>
    TEXT
  end

  def notify_advisers(report)
    report.user.company.advisers.each do |adviser|
      NotificationFacade.trainee_report(report, adviser)
      create_advisers_watch(report, adviser)
    end
  end

  def notify_consecutive_sad_report(report)
    User.mentor.each do |receiver|
      ActivityDelivery.with(report:, receiver:).notify(:consecutive_sad_report)
    end
  end

  def notify_followers(report)
    report.user.followers.each do |follower|
      ActivityDelivery.with(sender: report.user, receiver: follower, report:).notify(:following_report)
      create_following_watch(report, follower) if follower.watching?(report.user)
    end
  end

  def create_advisers_watch(report, adviser)
    Watch.create!(user: adviser, watchable: report)
  end

  def create_following_watch(report, follower)
    Watch.create!(user: follower, watchable: report)
  end
end
