# frozen_string_literal: true

require 'application_system_test_case'

class Company::UsersTest < ApplicationSystemTestCase
  setup { login_user 'komagata', 'testtest' }

  test 'show users' do
    visit "/companies/#{companies(:company1).id}/users"
    assert_equal 'Fjord Inc.所属ユーザー | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end
end
