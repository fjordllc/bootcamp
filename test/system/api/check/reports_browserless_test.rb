# frozen_string_literal: true

require 'browserless_system_test_case'

class Check::ReportsBrowserlessTest < BrowserlessSystemTestCase
  test 'non admin user is non botton' do
    visit_with_auth "/reports/#{reports(:report2).id}", 'kimura'
    assert_not has_button? '日報を確認'
  end

  test 'user can see stamp' do
    visit_with_auth "/reports/#{reports(:report1).id}", 'kimura'
    assert_text '確認済'
  end
end
