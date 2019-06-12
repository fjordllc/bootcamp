# frozen_string_literal: true

require "application_system_test_case"

class User::WorksTest < ApplicationSystemTestCase
  setup { login_user "hatsuno", "testtest" }

  test "show portfolio" do
    visit "/users/#{users(:hatsuno).id}/portfolio"
    assert_equal "hatsunoのポートフォリオ | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end
end
