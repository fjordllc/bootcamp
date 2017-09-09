require "test_helper"

class SendTaskRequestTest < ActionDispatch::IntegrationTest
  test "should be success when upload image file" do
    login_user("tanaka", "testtest")
    assert_equal current_path, "/users"
    click_link "プラクティス"
    click_link "viをインストールする"
    assert_not has_link? "完了"
    assert has_button? "課題の確認を依頼する"
    fill_in("task_request_content", with: "課題が完了しました。宜しくお願い致します。")
    attach_file("task_request_task", Rails.root + "app/assets/images/kowabana.png")
    click_button "課題の確認を依頼する"
    assert_not has_link? "課題の確認を依頼する"
    assert_text "提出した課題の内容"
    assert_text "課題が完了しました。宜しくお願い致します。"
    assert_text "kowabana.png"
    assert_text "KB"
  end

  test "should be success when upload ZIP file" do
    login_user("tanaka", "testtest")
    assert_equal current_path, "/users"
    click_link "プラクティス"
    click_link "viをインストールする"
    assert_not has_link? "完了"
    assert has_button? "課題の確認を依頼する"
    fill_in("task_request_content", with: "課題が完了しました。宜しくお願い致します。")
    attach_file("task_request_task", Rails.root + "test/sample_file/sample.zip")
    click_button "課題の確認を依頼する"
    assert_not has_link? "課題の確認を依頼する"
    assert_text "提出した課題の内容"
    assert_text "課題が完了しました。宜しくお願い致します。"
    assert_text "sample.zip"
    assert_text "KB"
  end

  test "not success when upload other file" do
    login_user("tanaka", "testtest")
    assert_equal current_path, "/users"
    click_link "プラクティス"
    click_link "viをインストールする"
    assert_not has_link? "完了"
    assert has_button? "課題の確認を依頼する"
    fill_in("task_request_content", with: "課題が完了しました。宜しくお願い致します。")
    attach_file("task_request_task", Rails.root + "test/sample_file/file.txt")
    click_button "課題の確認を依頼する"
    assert_not has_link? "課題の確認を依頼する"
    assert_no_text "提出した課題の内容"
    assert_no_text "課題が完了しました。宜しくお願い致します。"
    assert_no_text "file.txt"
    assert_no_text "KB"
  end
end
