# frozen_string_literal: true

require "application_system_test_case"

class NotificationsTest < ApplicationSystemTestCase
  test "notifications" do
    login_user "sotugyou", "testtest"

    visit "/"
    find(".test-show-notifications").click
    assert_text "komagataさんからコメントが届きました。"
    assert_text "machidaさんが学習週1日目を確認しました。"
    assert_text "komagataさんからメンションがきました。"
    assert_no_text "machidaさんからコメントが届きました。"
  end

  test "GET /notifications" do
    login_user "sotugyou", "testtest"

    visit "/notifications"
    assert_text "komagataさんからコメントが届きました。"
    assert_text "machidaさんが学習週1日目を確認しました。"
    assert_text "komagataさんからメンションがきました。"
    assert_text "machidaさんからコメントが届きました。"
  end

  test "notifications_allmarks" do
    login_user "sotugyou", "testtest"
    visit "/notifications"
    click_link('全て既読にする')
    assert_text "全て既読にしました"
  end
end
