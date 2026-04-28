# frozen_string_literal: true

require 'test_helper'

class FirstReportNotifierTest < ActiveSupport::TestCase
  test 'notifies admins and mentors only when first report is initially posted' do
    report = build_wip_report(users(:nippounashi))
    notifier = FirstReportNotifier.new

    assert_no_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count } do
      notifier.call('report.create', Time.current, Time.current, 'unique_id', report:)
    end

    report.update!(wip: false)
    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, User.admins_and_mentors.count do
      notifier.call('report.update', Time.current, Time.current, 'unique_id', report:)
    end

    Notification.create!(
      kind: :first_report,
      user: users(:machida),
      sender: report.user,
      message: "#{report.user.login_name}さんがはじめての日報を書きました！",
      link: "/reports/#{report.id}",
      read: false
    )

    assert_no_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count } do
      notifier.call('report.update', Time.current, Time.current, 'unique_id', report:)
    end
  end

  private

  def build_wip_report(user)
    user.reports.destroy_all
    Report.create!(
      user:,
      title: '初めての日報を提出したら',
      description: 'ユーザーに通知をする',
      reported_on: Date.current,
      wip: true,
      published_at: nil
    )
  end
end
