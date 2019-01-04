# frozen_string_literal: true

require "application_system_test_case"

class HomeTest < ApplicationSystemTestCase
  test "GET / without sign in" do
    logout
    visit "/"
    assert_equal "FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "GET /" do
    login_user "komagata", "testtest"
    visit "/"
    assert_equal "ダッシュボード | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end
end
