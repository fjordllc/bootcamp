require "test_helper"

class AdminCompletesPracticeTest < ActionDispatch::IntegrationTest
  fixtures :artifacts

  test "admin user checking for non_passed task request" do
    login_user "komagata", "testtest"
    assert page.find(:css, ".global-nav-artifact-count", text: "4")

    click_link "成果物"
    assert_text "viをインストールする"

    click_link "確認済"
    assert_no_text "viをインストールする"

    click_link "未確認"
    assert_text "viをインストールする"
    page.all(".admin-table__item-value.is-text-align-center")[2].click_link("成果物")
    click_link "完了"
    assert_text "依頼された課題の確認を完了しました。"

    assert page.find(:css, ".global-nav-artifact-count", text: "3")
    assert_no_text "viをインストールする"

    click_link "確認済"
    assert_text "viをインストールする"
  end
end
