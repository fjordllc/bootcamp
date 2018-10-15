require "application_system_test_case"

class Notification::AnswersTest < ApplicationSystemTestCase
  setup do
    @notice_text = "komagataさんから回答がありました。"
  end

  test "recieve a notification when I got my question's answer" do
    login_user "komagata", "testtest"
    visit "/questions/#{questions(:question_2).id}"
    within("#new_answer") do
      fill_in("answer[description]", with: "reduceも使ってみては？")
    end
    click_button "コメントを投稿"
    logout

    login_user "tanaka", "testtest"
    first(".test-bell").click
    assert_text @notice_text
    logout

    login_user "komagata", "testtest"
    refute_text @notice_text
  end
end
