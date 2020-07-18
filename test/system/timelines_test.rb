# frozen_string_literal: true

require "application_system_test_case"

class TimelinesTest < ApplicationSystemTestCase
  setup { login_user "kimura", "testtest" }

  test "can see the past timelines when visit the timeline page" do
    visit "/timelines"
    assert_text "勉強中です"
  end

  test "post new timeline on realtime" do
    visit "/timelines"

    Capybara.session_name = :new_window
    login_user "hajime", "testtest"
    visit "/timelines"

    fill_in("new_timeline[description]", with: "初めての分報投稿です")
    click_button "投稿する"

    Capybara.session_name = :default

    assert_text "初めての分報投稿です"
  end

  test "edit the timeline on realtime" do
    visit "/timelines"
    assert_text "勉強中です"

    Capybara.session_name = :new_window
    login_user "hajime", "testtest"
    visit "timelines"

    within(".thread-timeline:first-child") do
      click_button "編集"
      within(:css, ".thread-timeline-form__form") do
        fill_in("timeline[description]", with: "勉強中でしたが、休憩します")
      end
      click_button "保存する"
    end

    Capybara.session_name = :default
    assert_text "勉強中でしたが、休憩します"
  end

  test "delete the timeline on realtime" do
    visit "/timelines"
    assert_text "勉強中です"

    Capybara.session_name = :new_window
    login_user "hajime", "testtest"
    visit "/timelines"

    within(".thread-timeline:first-child") do
      accept_alert do
        click_button("削除")
      end
    end

    Capybara.session_name = :default
    assert_no_text "勉強中です"
  end

  test "other user cannot edit and destroy timeline" do
    visit "/timelines"
    assert_no_selector "button", text: "編集"
    assert_no_selector "button", text: "削除"
  end

  test "submit_button is enabled after a post is done" do
    visit "/timelines"
    fill_in("new_timeline[description]", with: "Action Cableについて勉強中です")

    click_button "投稿する"
    assert_text "Action Cableについて勉強中です"

    fill_in("new_timeline[description]", with: "Vue.jsについて勉強中です")
    click_button "投稿する"
    assert_text "Vue.jsについて勉強中です"
  end

  test "when visit timelines page, 20 timelines are loaded. furthermore, when scroll to bottom, past 20 timelines are loaded." do
    visit "/timelines"

    # 分報が読み込まれるのを待つために1秒間sleep
    sleep 1

    assert_equal(20, all(:css, ".thread-timeline").size)

    # bottomまでスクロール
    page.execute_script "window.scrollTo(0, document.body.scrollHeight)"

    # 過去の分報が読み込まれるのを待つために1秒間sleep
    sleep 1

    assert_equal(40, all(:css, ".thread-timeline").size)
  end
end
