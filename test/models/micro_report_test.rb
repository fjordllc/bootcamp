# frozen_string_literal: true

require 'test_helper'

class MicroReportTest < ActiveSupport::TestCase
  def setup
    @user = users(:hatsuno)
  end

  test 'comment_user is automatically set to user when not specified' do
    user = users(:hatsuno)
    micro_report = MicroReport.new(user:, content: 'テスト')
    micro_report.save
    assert_equal user, micro_report.comment_user
  end

  test 'comment_user is not overwritten when already specified' do
    user = users(:hatsuno)
    other_user = users(:kimura)
    micro_report = MicroReport.new(user:, comment_user: other_user, content: 'テスト')
    micro_report.save
    assert_equal other_user, micro_report.comment_user
  end

  test '#path' do
    user = users(:komagata)
    micro_report = user.micro_reports.create!(content: 'test')
    assert_equal "/users/#{user.id}/micro_reports?micro_report_id=#{micro_report.id}", micro_report.path
  end

  test 'delete notifications when micro_report is deleted' do
    micro_report = @user.micro_reports.create!(content: 'mentioned')

    Notification.create!(
      kind: 'mentioned',
      user: @user,
      sender: @user,
      message: 'test',
      link: micro_report.path
    )

    assert_difference 'Notification.count', -1 do
      micro_report.destroy
    end
  end

  test '.page_number_for' do
    user = users(:kimura)
    scope = user.micro_reports
    per_page = 3
    reports = [
      user.micro_reports.create!(content: 'test1', created_at: '2026-01-01 00:00:00'),
      user.micro_reports.create!(content: 'test2', created_at: '2026-01-02 00:00:00'),
      user.micro_reports.create!(content: 'test3', created_at: '2026-01-03 00:00:00'),
      user.micro_reports.create!(content: 'test4', created_at: '2026-01-04 00:00:00')
    ]

    assert_equal 1, MicroReport.page_number_for(scope:, target: reports[0], per_page:)
    assert_equal 1, MicroReport.page_number_for(scope:, target: reports[2], per_page:)
    assert_equal 2, MicroReport.page_number_for(scope:, target: reports[3], per_page:)
  end
end
