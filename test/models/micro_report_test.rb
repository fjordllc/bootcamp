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
end
