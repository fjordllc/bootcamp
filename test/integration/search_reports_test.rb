require "test_helper"

class SearchReportsTest < ActionDispatch::IntegrationTest
  def setup
    @report_1 = reports(:report_1)
    @report_2 = reports(:report_2)
    @report_3 = reports(:report_3)
    @report_4 = reports(:report_4)
    @report_5 = reports(:report_5)
    @report_6 = reports(:report_6)
    @report_7 = reports(:report_7)
  end

  test "should be words search reports" do
    login_user "komagata", "testtest"
    assert_equal current_path, "/users"

    fill_in "word", with: "作業 2"
    find(".header-search__submit").click

    assert_text "'作業 2' の検索結果"
    assert_no_text @report_1.description
    assert_text @report_2.description
    assert_no_text @report_3.description
    assert_no_text @report_4.description
    assert_no_text @report_5.description
    assert_no_text @report_6.description
    assert_no_text @report_7.description

    fill_in "word", with: "学習 ruby"
    find(".header-search__submit").click

    assert_text "'学習 ruby' の検索結果"
    assert_no_text @report_1.description
    assert_no_text @report_2.description
    assert_no_text @report_3.description
    assert_no_text @report_4.description
    assert_text @report_5.description
    assert_no_text @report_6.description
    assert_no_text @report_7.description
  end
end
