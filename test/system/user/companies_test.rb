# frozen_string_literal: true

require 'application_system_test_case'

class User::CompaniesTest < ApplicationSystemTestCase
  test 'show companies' do
    visit_with_auth '/users/companies', 'komagata'
    assert_equal '企業一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
    assert_text companies(:company1).name
  end
  test 'not show no users companies' do
    visit_with_auth '/users/companies', 'komagata'
    assert_no_text companies(:company3).name
  end
end
