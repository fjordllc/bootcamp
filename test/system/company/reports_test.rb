# frozen_string_literal: true

require 'application_system_test_case'

class Company::ReportsTest < ApplicationSystemTestCase
  test 'show listing reports' do
    visit_with_auth "/companies/#{companies(:company1).id}/reports", 'kimura'
    assert_equal 'Fjord Inc.所属ユーザーの日報 | FBC', title
  end
end
