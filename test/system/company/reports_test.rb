# frozen_string_literal: true

require 'application_system_test_case'

class Company::ReportsTest < ApplicationSystemTestCase
  setup { login_user 'komagata', 'testtest' }

  test 'show listing reports' do
    visit "/companies/#{companies(:company1).id}/reports"
    assert_equal 'Fjord Inc.所属ユーザーの日報 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end
end
