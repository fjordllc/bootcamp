# frozen_string_literal: true

require 'test_helper'

class ReportCallbacksTest < ActiveSupport::TestCase
  test 'delete notifications when a report is destroyed' do
    author = users(:kimura)
    report = author.reports.create!(title: 'test title', description: 'test.', reported_on: Date.current)
    Notification.create!(
      kind: :first_report,
      user: users(:komagata),
      sender: author,
      message: "#{author.login_name}さんがはじめての日報を書きました！",
      link: "/reports/#{report.id}",
      read: false
    )

    assert_difference -> { Notification.where(link: "/reports/#{report.id}").count }, -1 do
      report.destroy!
    end
  end
end
