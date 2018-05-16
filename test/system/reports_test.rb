require "application_system_test_case"

class ReportsTest < ApplicationSystemTestCase
  def setup
    login_user "komagata", "testtest"
  end

  def practices
    visit "/practices"
    all(".category-practices-item__value.is-title").map { |e| e.text }
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
    select "50", from: selects[1]["id"]
    select "08", from: selects[2]["id"]
    select "50", from: selects[3]["id"]

    click_link "学習時間追加"
    selects = all("select")
    select "08", from: selects[4]["id"]
    select "50", from: selects[5]["id"]
    select "09", from: selects[6]["id"]
    select "50", from: selects[7]["id"]

    click_link "学習時間追加"
    selects = all("select")
    select "19", from: selects[8]["id"]
    select "30", from: selects[9]["id"]
    select "20", from: selects[10]["id"]
    select "10", from: selects[11]["id"]

    click_button "登録する"

    assert_text "2時間40分"
    assert_text "07:50 〜 08:50"
    assert_text "08:50 〜 09:50"
    assert_text "19:30 〜 20:10"
  end

  test "register learning_times 2h" do
    visit "/reports/new"
    fill_in "report_title", with: "テスト日報 成功"
    fill_in "report_description", with: "不具合再現の結合テストコード"

    selects = all("select")
    select "07", from: selects[0]["id"]
    select "50", from: selects[1]["id"]
    select "08", from: selects[2]["id"]
    select "50", from: selects[3]["id"]

    click_link "学習時間追加"
    selects = all("select")
    select "08", from: selects[4]["id"]
    select "50", from: selects[5]["id"]
    select "09", from: selects[6]["id"]
    select "50", from: selects[7]["id"]

    click_button "登録する"

    assert_text "2時間\n"
    assert_text "07:50 〜 08:50"
    assert_text "08:50 〜 09:50"
  end
  
  test "register learning_times 1h40m" do
    visit "/reports/new"
    fill_in "report_title", with: "テスト日報 成功"
    fill_in "report_description", with: "不具合再現の結合テストコード"

    selects = all("select")
    select "07", from: selects[0]["id"]
    select "50", from: selects[1]["id"]
    select "08", from: selects[2]["id"]
    select "50", from: selects[3]["id"]

    click_link "学習時間追加"
    selects = all("select")
    select "19", from: selects[4]["id"]
    select "30", from: selects[5]["id"]
    select "20", from: selects[6]["id"]
    select "10", from: selects[7]["id"]

    click_button "登録する"

    assert_text "1時間40分\n"
    assert_text "07:50 〜 08:50"
    assert_text "19:30 〜 20:10"
  end

  test "register learning_time 40m" do
    visit "/reports/new"
    fill_in "report_title", with: "テスト日報 成功"
    fill_in "report_description", with: "不具合再現の結合テストコード"

    selects = all("select")
    select "19", from: selects[0]["id"]
    select "30", from: selects[1]["id"]
    select "20", from: selects[2]["id"]
    select "10", from: selects[3]["id"]

    click_button "登録する"

    assert_text "40分\n"
    assert_text "19:30 〜 20:10"
  end
end
