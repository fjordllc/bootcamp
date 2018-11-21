# frozen_string_literal: true

require "application_system_test_case"

class User::PracticesTest < ApplicationSystemTestCase
  setup { login_user "hatsuno", "testtest" }

  test "show listing practices" do
    visit "/users/#{users(:hatsuno).id}/practices"
    assert_equal "hatsunoのプラクティス | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end
end
