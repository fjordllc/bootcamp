# frozen_string_literal: true

require "application_system_test_case"

class WorksTest < ApplicationSystemTestCase
  test "user can see user's own work" do
    login_user "kimura", "testtest"
    visit work_path(works(:work_1))
    assert_text "kimura's app"
  end

  test "user can see other user's work" do
    login_user "kimura", "testtest"
    visit work_path(works(:work_2))
    assert_text "hatsuno's app"
  end

  test "create a work" do
    login_user "kimura", "testtest"
    visit new_work_path
    fill_in("work[title]", with: "kimura's app2")
    fill_in("work[repository]", with: "http://kimurasapp2.com")
    fill_in("work[description]", with: "木村のアプリ2です")
    click_button "登録する"
    assert_text "ポートフォリオに作品を追加しました"
  end

  test "update my work" do
    login_user "kimura", "testtest"
    visit work_path(works(:work_1))
    click_link "内容修正"
    fill_in("work[description]", with: "木村のアプリです。頑張りました")
    click_button "更新する"
    assert_text "作品を更新しました"
  end

  test "destroy my work" do
    login_user "kimura", "testtest"
    visit work_path(works(:work_1))
    accept_confirm do
      click_link "削除"
    end
    assert_text "ポートフォリオから作品を削除しました"
  end

  test "admin can update a work" do
    login_user "komagata", "testtest"
    visit work_path(works(:work_1))
    click_link "内容修正"
    fill_in("work[description]", with: "木村のアプリです。頑張りました")
    click_button "更新する"
    assert_text "作品を更新しました"
  end

  test "admin can destroy a work" do
    login_user "komagata", "testtest"
    visit work_path(works(:work_1))
    accept_confirm do
      click_link "削除"
    end
    assert_text "ポートフォリオから作品を削除しました"
  end

  test "user can't update other user's work" do
    login_user "kimura", "testtest"
    visit work_path(works(:work_2))
    assert_no_text "内容修正"
  end

  test "user can't destroy other user's work" do
    login_user "kimura", "testtest"
    visit work_path(works(:work_2))
    assert_no_text "削除"
  end
end
