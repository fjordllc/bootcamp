require "application_system_test_case"

class CheckProductTest < ApplicationSystemTestCase
  test "Success Product Checking" do
    login_user "machida", "testtest"
    click_link "プラクティス"
    assert_text "OS X Mountain Lionをクリーンインストールする"
    click_link "OS X Mountain Lionをクリーンインストールする"
    
    page.first(".user-reports-item__link").click
    assert has_button? "提出物を確認"
    click_button "提出物を確認"
    assert_not has_button? "提出物を確認"
    assert_text "この提出物を確認しました。"
    visit reports_path
    assert_text "確認済"
  end
end
