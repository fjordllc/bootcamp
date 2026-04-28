# frozen_string_literal: true

require 'test_helper'

class ReportNotifierTest < ActiveSupport::TestCase
  test 'notifies mention target only when report is initially posted' do
    author = users(:machida)
    receiver = users(:kimura)
    report = build_wip_report(author, title: '初めて提出したら、', description: "@#{receiver.login_name} に通知する")

    assert_notify_only_when_initially_posted(report, -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count })
  end

  test 'notifies company advisor only when report is initially posted' do
    author = users(:kensyu)
    report = build_wip_report(author, title: '研修生が日報を作成し提出した時', description: 'アドバイザーに通知を飛ばす')

    assert_notify_only_when_initially_posted(report, -> { AbstractNotifier::Testing::Driver.deliveries.count })
  end

  test 'notifies follower only when report is initially posted' do
    following = Following.find_by!(follower: users(:kensyu), followed: users(:muryou))
    author = following.followed
    report = build_wip_report(author, title: '初めて提出した時だけ', description: 'フォローされているユーザーに通知を飛ばす')

    assert_notify_only_when_initially_posted(report, -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count })
  end

  private

  def build_wip_report(user, title:, description:)
    user.reports.destroy_all
    Report.create!(
      user:,
      title:,
      description:,
      reported_on: Date.current,
      wip: true,
      published_at: nil
    )
  end

  def assert_notify_only_when_initially_posted(report, notification_count)
    notifier = ReportNotifier.new

    assert_no_difference notification_count do
      notifier.call('report.create', Time.current, Time.current, 'unique_id', report:)
    end

    report.update!(wip: false, description: "#{report.description}\n公開")
    assert_difference notification_count, 1 do
      notifier.call('report.update', Time.current, Time.current, 'unique_id', report:)
    end

    report.reload.update!(description: "#{report.description}\n更新")
    assert_no_difference notification_count do
      notifier.call('report.update', Time.current, Time.current, 'unique_id', report:)
    end
  end
end
