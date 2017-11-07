require "test_helper"

class FootprintTest < ActionDispatch::IntegrationTest
  setup { login_user "tanaka", "testtest" }

  test "should be create footprint" do
    assert_equal current_path, "/users"
    click_link "日報"
    assert_text "作業週2日目"
    click_link "作業週2日目"
    assert_text "見たよ"
    assert page.has_css?(".footprints-item__checker-icon.is-tanaka")
  end

  test "should not footpoint with my report" do
    assert_equal current_path, "/users"
    click_link "日報"
    assert_text "学習週3日目"
    click_link "学習週3日目"
    assert_no_text "見たよ"
    assert_not page.has_css?(".footprints-item__checker-icon.is-tanaka")
  end
end
