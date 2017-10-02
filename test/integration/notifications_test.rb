require "test_helper"

class NotificationsTest < ActionDispatch::IntegrationTest
  test "notifications" do
    login_user "tanaka", "testtest"

    visit "/"
    first(".header-links__link.js-drop-down__trigger").click
    assert_text "komagataさんからコメントが届きました。"
    assert_text "machidaさんが学習週1日目を確認しました。"
    assert_text "komagataさんからメンションがきました。"
    assert_no_text "machidaさんからコメントが届きました。"
  end
end
