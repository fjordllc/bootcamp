# frozen_string_literal: true

require 'browserless_system_test_case'

class MicroReportsBrowserlessTest < BrowserlessSystemTestCase
  setup do
    Switchlet.enable!(:micro_report)
  end

  test 'show all micro reports of the target user' do
    visit_with_auth user_micro_reports_path(users(:hajime)), 'hatsuno'
    assert_text '自分の分報'
    assert_text '最初の分報'
    assert_text '2つ目の分報'
    assert_text '最新の分報'
  end

  test 'micro reports are ordered by created_at asc' do
    visit_with_auth user_micro_reports_path(users(:hajime)), 'hatsuno'
    within('.micro-reports__items') do
      assert_selector '.micro-report', count: 3
      within first('.micro-report') do
        assert_text '最初の分報'
      end

      within all('.micro-report').last do
        assert_text '最新の分報'
      end
    end
  end

  test 'form has micro report tab and preview tab' do
    visit_with_auth user_micro_reports_path(users(:hatsuno)), 'hatsuno'
    within('.micro-report-form-tabs') do
      assert_text '分報'
      assert_text 'プレビュー'
    end
  end

  test 'only owner and admin can delete micro_reports' do
    micro_report = micro_reports(:hajime_first_micro_report)
    visit_with_auth user_micro_reports_path(users(:hajime)), 'hajime'
    within(".micro-report#micro_report_#{micro_report.id}") { assert_selector 'a', text: '削除する' }

    visit_with_auth user_micro_reports_path(users(:hajime)), 'komagata'
    within(".micro-report#micro_report_#{micro_report.id}") { assert_selector 'a', text: '削除する' }

    visit_with_auth user_micro_reports_path(users(:hajime)), 'mentormentaro'
    within(".micro-report#micro_report_#{micro_report.id}") { assert_no_selector 'a', text: '削除する' }
  end

  test 'redirects to target micro_report page if micro_report_id is given as a query parameter' do
    user = users(:hatsuno)

    per_page = Users::MicroReportsController::PAGER_NUMBER
    user.micro_reports.destroy_all
    user.micro_reports.create!(Array.new(per_page) { |i| { content: "#{i + 1}個目の分報" } })
    target_micro_report = user.micro_reports.create!(content: '2ページ目の分報')

    visit_with_auth user_micro_reports_path(user, micro_report_id: target_micro_report.id), user.login_name
    assert_current_path user_micro_reports_path(user, page: 2), ignore_query: false
    assert_selector "#micro_report_#{target_micro_report.id}", text: '2ページ目の分報'
  end

  test 'redirects to micro_report index with alert if target micro_report_id does not exist' do
    user = users(:hatsuno)

    visit_with_auth user_micro_reports_path(user, micro_report_id: -1), user.login_name

    assert_current_path user_micro_reports_path(user)
    assert_selector '.flash__message', text: '指定された分報は見つかりませんでした。'
  end
end
