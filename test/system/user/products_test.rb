# frozen_string_literal: true

require 'application_system_test_case'

class User::ProductsTest < ApplicationSystemTestCase
  test 'show listing products' do
    visit_with_auth "/users/#{users(:hatsuno).id}/products", 'komagata'
    assert_equal 'hatsunoの提出物 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end
end
