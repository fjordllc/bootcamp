# frozen_string_literal: true

require "application_system_test_case"

class Practice::ReportsTest < ApplicationSystemTestCase
  setup { login_user "hatsuno", "testtest" }

  test "show listing reports" do
    visit "/practices/#{practices(:practice_1).id}/reports"
    assert_equal "OS X Mountain Lionをクリーンインストールするの日報 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end
end
