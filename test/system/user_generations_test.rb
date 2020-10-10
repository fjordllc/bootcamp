# frozen_string_literal: true

require "application_system_test_case"

class UserGenerationsTest < ApplicationSystemTestCase
  test "show same generation users" do
    login_user "kimura", "testtest"
    visit user_generation_path(users(:kimura).generation)
    assert_equal "#{users(:kimura).generation}期のユーザー一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
    assert_text users(:kimura).name
    assert_text users(:komagata).name
  end
end
