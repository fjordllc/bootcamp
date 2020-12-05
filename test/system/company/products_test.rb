# frozen_string_literal: true

require 'application_system_test_case'

class Company::ProductsTest < ApplicationSystemTestCase
  setup { login_user 'komagata', 'testtest' }

  test 'show listing products' do
    visit "/companies/#{companies(:company_1).id}/products"
    assert_equal 'FJORD, LLC所属ユーザーの提出物 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end
end
