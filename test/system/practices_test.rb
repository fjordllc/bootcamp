# frozen_string_literal: true

require "application_system_test_case"

class PracticesTest < ApplicationSystemTestCase
  test "show practice" do
    login_user "hatsuno", "testtest"
    visit "/practices/#{practices(:practice_1).id}"
    assert_equal "OS X Mountain Lionをクリーンインストールする | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "finish a practice" do
    login_user "komagata", "testtest"

    visit "/practices/#{practices(:practice_1).id}"
    find("#js-complete").click
    assert_not has_link? "完了"
  end

  test "show [提出物を作る] or [提出物] link if user don't have to submit product" do
    login_user "machida", "testtest"

    visit "/practices/#{practices(:practice_1).id}"
    assert_link "提出物を作る"
  end

  test "don't show [提出物を作る] link if user don't have to submit product" do
    login_user "yamada", "testtest"

    visit "/practices/#{practices(:practice_1).id}"
    assert_no_link "提出物を作る"
  end
end
