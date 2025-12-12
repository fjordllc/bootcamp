# frozen_string_literal: true

require 'test_helper'

class MicroReportTest < ActiveSupport::TestCase
  test '#path' do
    user = users(:komagata)
    micro_report = user.micro_reports.create!(content: 'test')
    assert_equal micro_report.path, "/users/#{user.id}/micro_reports?micro_report_id=#{micro_report.id}"
  end
end
