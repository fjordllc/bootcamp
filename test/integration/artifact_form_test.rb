require "test_helper"

class ArtifactFormTest < ActionDispatch::IntegrationTest
  test "sucess create from artifact" do
    login_user("tanaka", "testtest")
    click_link "プラクティス"
    click_link "viをインストールする"
    assert_not has_button? "完了"
    assert has_button? "提出する"
    fill_in("artifact_content", with: "課題が完了しました。宜しくお願い致します。")
    click_button "提出する"
    assert_text "課題の成果物を提出しました。"
  end
end
