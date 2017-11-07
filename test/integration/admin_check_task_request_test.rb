require "test_helper"

class AdminCheckTaskRequestTest < ActionDispatch::IntegrationTest
  fixtures :task_requests

  test "admin user checking for non_passed task request" do
    login_user "komagata", "testtest"
    assert page.find(:css, ".global-nav-task_requests-count", text: "4")

    click_link "課題の確認依頼"
    assert_text "viをインストールする"

    click_link "確認済"
    assert_no_text "viをインストールする"

    click_link "未確認"
    assert_text "viをインストールする"
    page.all(".admin-table__item-value.is-text-align-center")[2].click_link("確認依頼の内容")
    assert_text "viをインストールするの課題完了しました。"
    click_link "完了"

    assert page.find(:css, ".global-nav-task_requests-count", text: "3")
    assert_no_text "viをインストールする"

    click_link "確認済"
    assert_text "viをインストールする"
  end
end
