# frozen_string_literal: true

require 'application_system_test_case'

class Report::ReportsViewSystemTest < ApplicationSystemTestCase
  setup do
    @student = users(:kimura)

    Notification.stub(:create!, nil) do
      Watch.stub(:create!, nil) do
        @unchecked_report1 = Report.create!(
          user: @student,
          title: '未チェックレポート1',
          description: 'テスト用レポート1',
          reported_on: Time.zone.today - 2,
          published_at: nil
        )

        @unchecked_report2 = Report.create!(
          user: @student,
          title: '未チェックレポート2',
          description: 'テスト用レポート2',
          reported_on: Time.zone.today - 1,
          published_at: nil
        )
      end
    end
  end

  test 'mentor sees unchecked reports links' do
    visit_with_auth reports_unchecked_index_path, 'komagata'

    assert_selector "a.js-unconfirmed-link[href='#{report_path(@unchecked_report1)}']", count: 1
    assert_selector "a.js-unconfirmed-link[href='#{report_path(@unchecked_report2)}']", count: 1
  end
end
