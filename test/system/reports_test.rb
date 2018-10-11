# frozen_string_literal: true

require "application_system_test_case"

class ReportsTest < ApplicationSystemTestCase
  def setup
    login_user "komagata", "testtest"
  end

  def practices
    visit "/practices"
    all(".category-practices-item__value.is-title").map { |e| e.text }
  end

  test "create a report" do
    visit "/reports/new"
    within("#new_report") do
      fill_in("report[title]", with: "test title")
      fill_in("report[description]",   with: "test")
    end
    click_button "WIP"
    assert_text "日報をWIPとして保存しました。"
  end

  test "create report as WIP" do
    visit "/reports/new"
    within("#new_report") do
      fill_in("report[title]", with: "test title")
      fill_in("report[description]",   with: "test")
    end
    click_button "提出"
    assert_text "日報を保存しました。"
  end

  test "equal practices order in practices and new report" do
    visit "/reports/new"
    report_practices = page.all(".select-practices__label-title").map { |e| e.text }
    assert_equal practices, report_practices
  end

  test "equal practices order in practices and edit report" do
    visit "/reports/#{reports(:report_1).id}/edit"
    report_practices = page.all(".select-practices__label-title").map { |e| e.text }
    assert_equal practices, report_practices
  end

  test "issue #360 duplicate" do
    visit "/reports/new"
    fill_in "report_title", with: "テスト日報"
    fill_in "report_description", with: "不具合再現の結合テストコード"

    selects = all("select")
    select "07", from: selects[0]["id"]
    select "30", from: selects[1]["id"]
    select "08", from: selects[2]["id"]
    select "30", from: selects[3]["id"]

    click_link "学習時間追加"
    selects = all("select")
    select "08", from: selects[4]["id"]
    select "30", from: selects[5]["id"]
    select "09", from: selects[6]["id"]
    select "30", from: selects[7]["id"]

    click_link "学習時間追加"
    selects = all("select")
    select "19", from: selects[8]["id"]
    select "30", from: selects[9]["id"]
    select "20", from: selects[10]["id"]
    select "15", from: selects[11]["id"]

    click_button "提出"

    assert_text "2時間45分"
    assert_text "07:30 〜 08:30"
    assert_text "08:30 〜 09:30"
    assert_text "19:30 〜 20:15"
  end

  test "register learning_times 2h" do
    visit "/reports/new"
    fill_in "report_title", with: "テスト日報 成功"
    fill_in "report_description", with: "不具合再現の結合テストコード"

    selects = all("select")
    select "07", from: selects[0]["id"]
    select "30", from: selects[1]["id"]
    select "08", from: selects[2]["id"]
    select "30", from: selects[3]["id"]

    click_link "学習時間追加"
    selects = all("select")
    select "08", from: selects[4]["id"]
    select "30", from: selects[5]["id"]
    select "09", from: selects[6]["id"]
    select "30", from: selects[7]["id"]

    click_button "提出"

    assert_text "2時間\n"
    assert_text "07:30 〜 08:30"
    assert_text "08:30 〜 09:30"
  end

  test "register learning_times 1h40m" do
    visit "/reports/new"
    fill_in "report_title", with: "テスト日報 成功"
    fill_in "report_description", with: "不具合再現の結合テストコード"

    selects = all("select")
    select "07", from: selects[0]["id"]
    select "30", from: selects[1]["id"]
    select "08", from: selects[2]["id"]
    select "30", from: selects[3]["id"]

    click_link "学習時間追加"
    selects = all("select")
    select "19", from: selects[4]["id"]
    select "30", from: selects[5]["id"]
    select "20", from: selects[6]["id"]
    select "15", from: selects[7]["id"]

    click_button "提出"

    assert_text "1時間45分\n"
    assert_text "07:30 〜 08:30"
    assert_text "19:30 〜 20:15"
  end

  test "register learning_time 45m" do
    visit "/reports/new"
    fill_in "report_title", with: "テスト日報 成功"
    fill_in "report_description", with: "不具合再現の結合テストコード"

    selects = all("select")
    select "19", from: selects[0]["id"]
    select "30", from: selects[1]["id"]
    select "20", from: selects[2]["id"]
    select "15", from: selects[3]["id"]

    click_button "提出"

    assert_text "45分\n"
    assert_text "19:30 〜 20:15"
  end

  test "regist learning_times 1h" do
    visit "/reports/new"
    fill_in "report_title", with: "テスト日報"
    fill_in "report_description", with: "完了日時 - 開始日時 < 0のパターン"

    selects = all("select")
    select "23", from: selects[0]["id"]
    select "00", from: selects[1]["id"]
    select "00", from: selects[2]["id"]
    select "00", from: selects[3]["id"]

    click_button "提出"

    assert_text "1時間\n"
    assert_text "23:00 〜 00:00"
  end

  test "regist learning_times 4h" do
    visit "/reports/new"
    fill_in "report_title", with: "テスト日報"
    fill_in "report_description", with: "複数時間登録のパターン"

    selects = all("select")
    select "22", from: selects[0]["id"]
    select "00", from: selects[1]["id"]
    select "00", from: selects[2]["id"]
    select "00", from: selects[3]["id"]

    click_link "学習時間追加"
    selects = all("select")
    select "00", from: selects[4]["id"]
    select "30", from: selects[5]["id"]
    select "02", from: selects[6]["id"]
    select "30", from: selects[7]["id"]

    click_button "提出"

    assert_text "4時間\n"
    assert_text "22:00 〜 00:00"
    assert_text "00:30 〜 02:30"
  end

  test "Should not have a link to previous report on the first report" do
    visit "/reports/#{reports(:report_1).id}"
    assert_no_text "前"
    assert_text "次"
  end

  test "Should have links to previous & next report" do
    visit "/reports/#{reports(:report_2).id}"
    assert_text "前"
    assert_text "次"
  end

  test "Should not have a link to  next report in the newest report" do
    visit "/reports/#{reports(:report_3).id}"
    assert_text "前"
    assert_no_text "次"
  end
end
