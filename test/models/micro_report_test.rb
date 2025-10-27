# frozen_string_literal: true

require 'test_helper'

class MicroReportTest < ActiveSupport::TestCase
  test '#path' do
    micro_report = users(:komagata).micro_reports.create!(content: 'test')
    assert_equal micro_report.path, "/users/#{users(:komagata).id}/micro_reports"
  end
end
