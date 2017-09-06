require "test_helper"

class LearningStatusTest < ActionDispatch::IntegrationTest
  test "learning status with mineo" do
    login_user "mineo", "testtest"

    assert_equal current_path, "/users"
    click_link "プラクティス"
    assert_selector ".status_stamp.checking", text: "確認中", count: 3
    assert_selector ".status_stamp.complete", text: "完了", count: 0
  end

  test "learning status with tanaka" do
    login_user "tanaka", "testtest"

    assert_equal current_path, "/users"
    click_link "プラクティス"
    assert_selector ".status_stamp.checking", text: "確認中", count: 1
    assert_selector ".status_stamp.complete", text: "完了", count: 1
  end
end
