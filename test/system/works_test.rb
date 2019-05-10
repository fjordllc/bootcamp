# frozen_string_literal: true

require "application_system_test_case"

class WorksTest < ApplicationSystemTestCase
  setup { login_user "kimura", "testtest" }

  test "user can see user's own work" do
    visit work_path(works(:work_1))
    assert_text "kimura's app"
  end

  test "user can see other user's work" do
    visit work_path(works(:work_2))
    assert_text "hatsuno's app"
  end

  test "create a work" do
    visit new_work_path
    fill_in("work[title]", with: "kimura's app2")
    fill_in("work[repository]", with: "http://kimurasapp2.com")
    fill_in("work[description]", with: "木村のアプリ2です")
    click_button "登録する"
    assert_text "ポートフォリオに作品を追加しました"
  end

  test "update a work" do
    visit edit_work_path(works(:work_1))
    fill_in("work[description]", with: "木村のアプリです。頑張りました")
    click_button "更新する"
    assert_text "作品を更新しました"
  end

  test "destroy a work" do
    visit work_path(works(:work_1))
    accept_confirm do
      click_link "削除"
    end
    assert_text "ポートフォリオから作品を削除しました"
  end
end
