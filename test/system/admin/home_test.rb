# frozen_string_literal: true

require "application_system_test_case"

class Admin::HomeTest < ApplicationSystemTestCase
  setup { login_user "komagata", "testtest" }

  test "GET /admin" do
    visit "/admin"
    assert_equal "管理ページ | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end
end
