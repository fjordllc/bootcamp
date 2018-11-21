# frozen_string_literal: true

require "application_system_test_case"

class User::ProductsTest < ApplicationSystemTestCase
  setup { login_user "komagata", "testtest" }

  test "show listing products" do
    visit "/users/#{users(:hatsuno).id}/products"
    assert_equal "hatsunoの提出物 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end
end
