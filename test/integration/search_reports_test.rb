require "test_helper"

class SearchReportsTest < ActionDispatch::IntegrationTest
  def setup
    @report_1 = reports(:report_1)
    @report_2 = reports(:report_2)
    @report_3 = reports(:report_3)
    @report_4 = reports(:report_4)
  end

  test "should be words search reports" do
    visit "/login"
    within("#sign-in-form") do
      fill_in("user[login_name]", with: "komagata")
      fill_in("user[password]", with: "testtest")
    end
    click_button "サインイン"
    assert_equal current_path, "/users"

    fill_in "word", with: "日"
    find(".header-search__submit").click

    assert_text "'日' の検索結果"
    assert_text @report_1.description
    assert_text @report_2.description
    assert_text @report_3.description
    assert_no_text @report_4.description

    fill_in "word", with: "css デザイン"
    find(".header-search__submit").click

    assert_text "'css デザイン' の検索結果"
    assert_no_text @report_1.description
    assert_no_text @report_2.description
    assert_text @report_3.description
    assert_text @report_4.description
  end
end
