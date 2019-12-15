# frozen_string_literal: true

require "application_system_test_case"

class EventsTest < ApplicationSystemTestCase
  test "show link to create new event when user is admin" do
    login_user "komagata", "testtest"
    visit events_path
    assert_link "イベント作成"
  end

  test "cannot create a new event when user is not admin" do
    login_user "kimura", "testtest"
    visit new_event_path
    assert_text "管理者としてログインしてください"
  end

  test "create a new event" do
    login_user "komagata", "testtest"
    visit new_event_path
    fill_in "event_title", with: "新しいイベント"
    fill_in "event_description", with: "イベントの説明文"
    fill_in "event_capacity", with: 20
    fill_in "event_location", with: "FJORDオフィス"
    fill_in "event_start_at", with: Time.zone.parse("2019-12-10 10:00")
    fill_in "event_end_at", with: Time.zone.parse("2019-12-10 12:00")
    fill_in "event_open_start_at", with: Time.zone.parse("2019-12-05 10:00")
    fill_in "event_open_end_at", with: Time.zone.parse("2019-12-09 23:59")
    assert_difference "Event.count", 1 do
      click_button "作成"
    end
    assert_text "イベントを作成しました。"
  end

  test "update event" do
    login_user "komagata", "testtest"
    visit edit_event_path(events(:event_1))
    fill_in "event_title", with: "ミートアップ(修正)"
    fill_in "event_description", with: "ミートアップを開催します(修正)"
    fill_in "event_capacity", with: 30
    fill_in "event_location", with: "FJORDオフィス"
    fill_in "event_start_at", with: Time.zone.parse("2019-12-21 19:00")
    fill_in "event_end_at", with: Time.zone.parse("2019-12-21 22:30")
    fill_in "event_open_start_at", with: Time.zone.parse("2019-12-11 9:00")
    fill_in "event_open_end_at", with: Time.zone.parse("2019-12-20 23:59")
    click_button "内容変更"
    assert_text "イベントを更新しました。"
  end

  test "destroy event" do
    login_user "komagata", "testtest"
    visit event_path(events(:event_1))
    accept_confirm do
      click_link "削除"
    end
    assert_text "イベントを削除しました。"
  end

  test "cannot create a new event when start_at > end_at" do
    login_user "komagata", "testtest"
    visit new_event_path
    fill_in "event_title", with: "開始日時 > 終了日時のイベント"
    fill_in "event_description", with: "エラーになる"
    fill_in "event_capacity", with: 20
    fill_in "event_location", with: "FJORDオフィス"
    fill_in "event_start_at", with: Time.zone.parse("2019-12-10 12:00")
    fill_in "event_end_at", with: Time.zone.parse("2019-12-10 10:00")
    fill_in "event_open_start_at", with: Time.zone.parse("2019-12-05 10:00")
    fill_in "event_open_end_at", with: Time.zone.parse("2019-12-09 23:59")
    click_button "作成"
    assert_text "終了日時は開始日時よりも後の日時にしてください。"
  end

  test "cannot create a new event when open_start_at > open_end_at" do
    login_user "komagata", "testtest"
    visit new_event_path
    fill_in "event_title", with: "募集開始日時 > 募集終了日時のイベント"
    fill_in "event_description", with: "エラーになる"
    fill_in "event_capacity", with: 20
    fill_in "event_location", with: "FJORDオフィス"
    fill_in "event_start_at", with: Time.zone.parse("2019-12-10 10:00")
    fill_in "event_end_at", with: Time.zone.parse("2019-12-10 12:00")
    fill_in "event_open_start_at", with: Time.zone.parse("2019-12-09 10:00")
    fill_in "event_open_end_at", with: Time.zone.parse("2019-12-07 10:00")
    click_button "作成"
    assert_text "募集終了日時は募集開始日時よりも後の日時にしてください。"
  end

  test "cannot create a new event when open_start_at > start_at" do
    login_user "komagata", "testtest"
    visit new_event_path
    fill_in "event_title", with: "募集開始日時 > 開始日時のイベント"
    fill_in "event_description", with: "エラーになる"
    fill_in "event_capacity", with: 20
    fill_in "event_location", with: "FJORDオフィス"
    fill_in "event_start_at", with: Time.zone.parse("2019-12-10 10:00")
    fill_in "event_end_at", with: Time.zone.parse("2019-12-10 12:00")
    fill_in "event_open_start_at", with: Time.zone.parse("2019-12-10 10:30")
    fill_in "event_open_end_at", with: Time.zone.parse("2019-12-10 11:30")
    click_button "作成"
    assert_text "募集開始日時は開始日時よりも前の日時にしてください。"
  end

  test "cannot create a new event when open_end_at > end_at" do
    login_user "komagata", "testtest"
    visit new_event_path
    fill_in "event_title", with: "募集終了日時 > 終了日時のイベント"
    fill_in "event_description", with: "エラーになる"
    fill_in "event_capacity", with: 20
    fill_in "event_location", with: "FJORDオフィス"
    fill_in "event_start_at", with: Time.zone.parse("2019-12-10 10:00")
    fill_in "event_end_at", with: Time.zone.parse("2019-12-10 12:00")
    fill_in "event_open_start_at", with: Time.zone.parse("2019-12-05 10:00")
    fill_in "event_open_end_at", with: Time.zone.parse("2019-12-11 12:00")
    click_button "作成"
    assert_text "募集終了日時は終了日時よりも前の日時にしてください。"
  end
end
