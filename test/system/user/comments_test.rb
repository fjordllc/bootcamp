# frozen_string_literal: true

require "application_system_test_case"

class User::CommentsTest < ApplicationSystemTestCase
  setup { login_user "hatsuno", "testtest" }

  test "show listing comments" do
    visit "/users/#{users(:hatsuno).id}/comments"
    assert_equal "hatsunoのコメント | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end
end
