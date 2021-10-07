# frozen_string_literal: true

require 'application_system_test_case'

class User::CompaniesTest < ApplicationSystemTestCase
  test 'show companies with users' do
    visit_with_auth '/users/companies', 'komagata'
    assert_equal '企業別 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
    assert_text companies(:company1).name
    assert_no_text companies(:company3).name
  end
end
