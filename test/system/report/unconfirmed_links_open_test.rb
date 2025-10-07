# frozen_string_literal: true

require 'application_system_test_case'

class Report::UnconfirmedLinksOpenTest < ApplicationSystemTestCase
  setup do
    @mentor = users(:komagata)
    @student = users(:kimura)

    Notification.stub(:create!, nil) do
      Watch.stub(:create!, nil) do
        @unchecked_report1 = Report.create!(
          user: @student,
          title: '未チェックレポート1',
          description: 'テスト用レポート1',
          reported_on: Time.zone.today - 2,
          published_at: 2.days.ago
        )

        @unchecked_report2 = Report.create!(
          user: @student,
          title: '未チェックレポート2',
          description: 'テスト用レポート2',
          reported_on: Time.zone.today - 1,
          published_at: 1.day.ago
        )
      end
    end
  end

  test 'mentor sees bulk open button when unchecked reports exist' do
    visit_with_auth reports_unchecked_index_path, 'komagata'
    assert_selector 'button', text: '未チェックの日報を一括で開く'
  end

  test 'mentor does not see bulk open button when no unchecked reports exist' do
    Report.unchecked.find_each do |report|
      report.checks.create!(user: @mentor)
    end

    visit_with_auth reports_unchecked_index_path, 'komagata'
    assert_no_selector 'button', text: '未チェックの日報を一括で開く'
  end

  # リンク存在を確認するテスト
  test 'mentor sees unchecked reports links' do
    visit_with_auth reports_unchecked_index_path, 'komagata'

    assert_selector "a.js-unconfirmed-link[href='#{report_path(@unchecked_report1)}']", count: 1
    assert_selector "a.js-unconfirmed-link[href='#{report_path(@unchecked_report2)}']", count: 1
  end
end
