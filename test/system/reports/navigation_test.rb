# frozen_string_literal: true

require 'application_system_test_case'

module Reports
  class NavigationTest < ApplicationSystemTestCase
    test 'previous report' do
      visit_with_auth "/reports/#{reports(:report2).id}", 'komagata'
      click_link '前の日報'
      assert_equal "/reports/#{reports(:report1).id}", current_path
    end

    test 'next report' do
      visit_with_auth "/reports/#{reports(:report2).id}", 'komagata'
      click_link '次の日報'
      assert_equal "/reports/#{reports(:report3).id}", current_path
    end

    test 'reports can be copied' do
      visit_with_auth report_path(users(:komagata).reports.first), 'komagata'
      travel 5.days do
        find('#copy').click
        assert_equal find('#report_reported_on').value, Date.current.strftime('%Y-%m-%d')
      end
    end

    test 'open new report with a past date' do
      visit_with_auth '/reports/new?reported_on=2022-1-1', 'komagata'
      assert_equal '2022-01-01', find('#report_reported_on').value
    end
  end
end
