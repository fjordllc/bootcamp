# frozen_string_literal: true

require "application_system_test_case"

class User::TimelinesTest < ApplicationSystemTestCase
  setup { login_user "kimura", "testtest" }

  test "can see the past timelines when visit the user timelines page" do
    visit "/users/#{users(:hajime).id}/timelines"
    assert_text "今は勉強中です"
  end

  test "if post a timeline to timelines page, it will be posted to user timelines page" do
    visit "/users/#{users(:hajime).id}/timelines"

    Capybara.session_name = :new_window
    login_user "hajime", "testtest"
    visit "/timelines"

    fill_in("new_timeline[description]", with: "初めての分報投稿です")
    click_button "投稿する"

    Capybara.session_name = :default

    assert_text "初めての分報投稿です"
  end

  test "if post a timeline to user timelines page, it will be posted to timelines page" do
    visit "/timelines"

    Capybara.session_name = :new_window
    login_user "hajime", "testtest"
    visit "/users/#{users(:hajime).id}/timelines"

    fill_in("new_timeline[description]", with: "初めての分報投稿です")
    click_button "投稿する"

    Capybara.session_name = :default

    assert_text "初めての分報投稿です"
  end

  test "if edit the timeline on timelines page, it will also be edited on user timelines page" do
    visit "/users/#{users(:hajime).id}/timelines"
    assert_text "今は勉強中です"

    Capybara.session_name = :new_window
    login_user "hajime", "testtest"
    visit "/timelines"

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

  test "if edit the timeline on user timelines page, it will also be edited on timelines page" do
    visit "/timelines"
    assert_text "今は勉強中です"

    Capybara.session_name = :new_window
    login_user "hajime", "testtest"
    visit "/users/#{users(:hajime).id}/timelines"

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

  test "if delete the timeline on timelines page, it will also be deleted on user timelines page" do
    visit "/users/#{users(:hajime).id}/timelines"
    assert_text "今は勉強中です"

    Capybara.session_name = :new_window
    login_user "hajime", "testtest"
    visit "/timelines"

    within(".thread-timeline:first-child") do
      accept_alert do
        click_button("削除")
      end
    end

    Capybara.session_name = :default
    assert_no_text "今は勉強中です"
  end

  test "if delete the timeline on user timelines page, it will also be deleted on timelines page" do
    visit "/timelines"
    assert_text "今は勉強中です"

    Capybara.session_name = :new_window
    login_user "hajime", "testtest"
    visit "/users/#{users(:hajime).id}/timelines"

    within(".thread-timeline:first-child") do
      accept_alert do
        click_button("削除")
      end
    end

    Capybara.session_name = :default
    assert_no_text "今は勉強中です"
  end

  test "other user cannot edit and destroy timeline on user timelines page" do
    visit "/users/#{users(:hajime).id}/timelines"
    assert_no_selector "button", text: "編集"
    assert_no_selector "button", text: "削除"
  end

  test "other user cannot see timeline form on user timelines page" do
    visit "/users/#{users(:hajime).id}/timelines"
    assert_no_selector "thread-timeline-form"
  end

  test "it won't be posted to other users timeline page." do
    visit "/users/#{users(:kimura).id}/timelines"
    assert_no_text "hajimeです"

    Capybara.session_name = :new_window
    login_user "hajime", "testtest"
    visit "/timelines"

    fill_in("new_timeline[description]", with: "hajimeです")
    click_button "投稿する"

    Capybara.session_name = :default

    assert_no_text "hajimeです"
  end

  test "when visit user timelines page, 20 timelines are loaded. furthermore, when scroll to bottom, past 20 timelines are loaded." do
    visit "/users/#{users(:hajime).id}/timelines"

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
