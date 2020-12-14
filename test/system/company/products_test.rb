# frozen_string_literal: true

require 'application_system_test_case'

class Company::ProductsTest < ApplicationSystemTestCase
  setup { login_user 'komagata', 'testtest' }

  test 'show listing products' do
    visit "/companies/#{companies(:company1).id}/products"
    assert_equal 'Fjord Inc.所属ユーザーの提出物 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end
end
