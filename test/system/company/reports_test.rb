# frozen_string_literal: true

require 'browserless_system_test_case'

class Company::ReportsTest < BrowserlessSystemTestCase
  test 'show listing reports' do
    visit_with_auth "/companies/#{companies(:company1).id}/reports", 'kimura'
    assert_equal 'Lokka Inc.所属ユーザーの日報 | FBC', title
  end
end
