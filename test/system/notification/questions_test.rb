# frozen_string_literal: true

require "application_system_test_case"

class Notification::QuestionsTest < ApplicationSystemTestCase
  setup do
    @notice_text = "hatsunoさんから質問がありました。"
    @notice_kind = Notification.kinds["came_question"]
    @notified_count = Notification.where(kind: @notice_kind).size
    @mentor_count = User.mentor.size
    practice = Practice.find_by(title: "OS X Mountain Lionをクリーンインストールする")
    @completed_student_count = practice.completed_learnings.size
  end

  test "mentor and completed student receive notification when question is posted" do
    login_user "hatsuno", "testtest"
    visit "/questions/new"
    within("#new_question") do
      fill_in("question[title]", with: "メンターに質問！！")
      fill_in("question[description]", with: "通知行ってますか？")
    end
    first(".select2-selection--single").click
    find("li", text: "[Mac OS X] OS X Mountain Lionをクリーンインストールする").click
    click_button "登録する"
    logout

    login_user "yamada", "testtest"
    first(".test-bell").click
    assert_text @notice_text
    logout

    login_user "kimura", "testtest"
    first(".test-bell").click
    assert_text @notice_text
    logout

    login_user "hajime", "testtest"
    refute_text @notice_text

    assert_equal @notified_count + @mentor_count + @completed_student_count, Notification.where(kind: @notice_kind).size
  end

  test "There is no notification to the mentor who posted" do
    login_user "yamada", "testtest"
    visit "/questions/new"
    within("#new_question") do
      fill_in("question[title]", with: "皆さんに質問！！")
      fill_in("question[description]", with: "通知行ってますか？")
    end
    first(".select2-selection--single").click
    find("li", text: "[Mac OS X] OS X Mountain Lionをクリーンインストールする").click
    click_button "登録する"
    logout

    login_user users(:yamada).login_name, "testtest"
    # 通知メッセージが非表示項目でassert_textでは取得できないため、findでvisible指定
    # 存在時、findは複数取得してエラーになるためassert_raisesにて検証
    assert_raises Capybara::ElementNotFound do
      find("yamadaさんから質問がありました。", visible: false)
    end
    logout
  end
end
