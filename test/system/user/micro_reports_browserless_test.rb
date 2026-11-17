# frozen_string_literal: true

require 'browserless_system_test_case'

class MicroReportsBrowserlessTest < BrowserlessSystemTestCase
  setup do
    Switchlet.enable!(:micro_report)
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

  test 'redirects to micro_report index with alert if target micro_report_id does not exist' do
    user = users(:hatsuno)

    visit_with_auth user_micro_reports_path(user, micro_report_id: -1), user.login_name

    assert_current_path user_micro_reports_path(user)
    assert_selector '.flash__message', text: '指定された分報は見つかりませんでした。'
  end
end
