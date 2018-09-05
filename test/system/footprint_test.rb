require "application_system_test_case"

class FootprintTest < ApplicationSystemTestCase
  test "should be create footprint" do
    visit "/login"
    within("#sign-in-form") do
      fill_in("user[login_name]", with: "tanaka")
      fill_in("user[password]", with: "testtest")
    end
    click_button "サインイン"
    assert_equal "/users", current_path
    click_link "日報"
    assert_text "作業週2日目"
    click_link "作業週2日目"
    assert_text "見たよ"
    assert page.has_css?(".footprints-item__checker-icon.is-tanaka")
  end

  test "should not footpoint with my report" do
    visit "/login"
    within("#sign-in-form") do
      fill_in("user[login_name]", with: "tanaka")
      fill_in("user[password]", with: "testtest")
    end
    click_button "サインイン"
    assert_equal "/users", current_path
    click_link "日報"
    assert_text "学習週3日目"
    click_link "学習週3日目"
    assert_no_text "見たよ"
    assert_not page.has_css?(".footprints-item__checker-icon.is-tanaka")
  end
end
