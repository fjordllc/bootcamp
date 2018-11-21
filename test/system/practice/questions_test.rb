# frozen_string_literal: true

require "application_system_test_case"

class Practice::QuestionsTest < ApplicationSystemTestCase
  setup { login_user "hatsuno", "testtest" }

  test "show listing questions" do
    visit "/practices/#{practices(:practice_1).id}/questions"
    assert_equal "OS X Mountain Lionをクリーンインストールするの質問 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end
end
