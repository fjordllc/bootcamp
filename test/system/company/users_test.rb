# frozen_string_literal: true

require 'application_system_test_case'

class Company::UsersTest < ApplicationSystemTestCase
  test 'show users' do
    visit_with_auth "/companies/#{companies(:company1).id}/users", 'kimura'
    assert_equal 'Fjord Inc.所属ユーザー | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end
end
