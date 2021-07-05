# frozen_string_literal: true

require 'application_system_test_case'

class Company::ProductsTest < ApplicationSystemTestCase
  test 'show listing products' do
    visit_with_auth "/companies/#{companies(:company1).id}/products", 'kimura'
    assert_equal 'Fjord Inc.所属ユーザーの提出物 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end
end
