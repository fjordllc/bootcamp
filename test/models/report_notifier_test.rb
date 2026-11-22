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

  test 'notifies mentors when reports with negative emotion are submitted twice in a row' do
    author = users(:kimura)
    author.reports.destroy_all
    notifier = ReportNotifier.new
    negative_notifications = lambda {
      AbstractNotifier::Testing::Driver.enqueued_deliveries.count { |delivery| delivery[:kind] == :consecutive_negative_report }
    }

    first = Report.create!(user: author, title: 'test title 1', description: 'test 1', reported_on: Date.current.prev_day, emotion: 'negative')
    assert_no_difference negative_notifications do
      notifier.call('report.create', Time.current, Time.current, 'unique_id', report: first)
    end

    second = Report.create!(user: author, title: 'test title 2', description: 'test 2', reported_on: Date.current, emotion: 'negative')
    assert_difference negative_notifications, User.mentor.count do
      notifier.call('report.create', Time.current, Time.current, 'unique_id', report: second)
    end
    delivery = AbstractNotifier::Testing::Driver.enqueued_deliveries.reverse.find { |d| d[:kind] == :consecutive_negative_report }
    assert_equal 'kimuraさんが2回連続でnegativeアイコンの日報を提出しました。', delivery[:body]
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
