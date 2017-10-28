require "test_helper"

class ReviewsTest < ActionDispatch::IntegrationTest
  test "should be success submissions review" do
    login_user("tanaka", "testtest")
    assert_equal current_path, "/users"
    click_link "プラクティス"
    click_link "PC性能の見方を知る"
    assert_not has_button? "完了"
    assert_text "レビュー"
    fill_in("review_message", with: "成果物を提出致します。よろしくお願いします。")
    click_button "レビューを投稿"
    assert_text "レビューを投稿しました。"
    assert_text "成果物を提出致します。よろしくお願いします。"
  end

  test "should be success update review" do
    login_user("tanaka", "testtest")
    visit edit_review_path(reviews(:tanaka_review))
    fill_in("review_message", with: "成果物の修正をしました。")
    click_button "レビューを修正する"
    assert_text "レビューの内容を更新しました。"
    assert_text "成果物の修正をしました。"
  end

  test "should be success destroy review" do
    login_user("tanaka", "testtest")
    assert_difference "Review.count", -1 do
      delete review_path(reviews(:tanaka_review))
    end
  end
end
