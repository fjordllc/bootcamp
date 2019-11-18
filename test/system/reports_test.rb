# frozen_string_literal: true

require "application_system_test_case"
require "minitest/mock"

class ReportsTest < ApplicationSystemTestCase
  def setup
    login_user "komagata", "testtest"
  end

  test "create report as WIP" do
    visit "/reports/new"
    within("#new_report") do
      fill_in("report[title]", with: "test title")
      fill_in("report[description]",   with: "test")
    end
    click_button "WIP"
    assert_text "日報をWIPとして保存しました。"
  end

  test "create a report" do
    visit "/reports/new"
    within("#new_report") do
      fill_in("report[title]", with: "test title")
      fill_in("report[description]",   with: "test")
      fill_in("report[reported_on]", with: Time.current)
    end

    all(".learning-time")[0].all(".learning-time__started-at select")[0].select("07")
    all(".learning-time")[0].all(".learning-time__started-at select")[1].select("30")
    all(".learning-time")[0].all(".learning-time__finished-at select")[0].select("08")
    all(".learning-time")[0].all(".learning-time__finished-at select")[1].select("30")

    click_button "提出"
    assert_text "日報を保存しました。"
    assert_text Time.current.strftime("%Y年%m月%d日")
  end

  test "equal practices order in practices and new report" do
    visit "/reports/new"
    first(".select2-selection--multiple").click
    report_practices = page.all(".select2-results__option").map { |e| e.text }
    assert_equal report_practices.count, Practice.count
    assert_match /OS X Mountain Lionをクリーンインストールする$/, first(".select2-results__option").text
    assert_match /Unityでのテスト$/, all(".select2-results__option").last.text
  end

  test "equal practices order in practices and edit report" do
    visit "/reports/#{reports(:report_1).id}/edit"
    first(".select2-selection--multiple").click
    report_practices = page.all(".select2-results__option").map { |e| e.text }
    assert_equal report_practices.count, Practice.count
    assert_match /OS X Mountain Lionをクリーンインストールする$/, first(".select2-results__option").text
    assert_match /Unityでのテスト$/, all(".select2-results__option").last.text
  end

  test "issue #360 duplicate" do
    visit "/reports/new"
    fill_in "report_title", with: "テスト日報"
    fill_in "report_description", with: "不具合再現の結合テストコード"

    all(".learning-time")[0].all(".learning-time__started-at select")[0].select("07")
    all(".learning-time")[0].all(".learning-time__started-at select")[1].select("30")
    all(".learning-time")[0].all(".learning-time__finished-at select")[0].select("08")
    all(".learning-time")[0].all(".learning-time__finished-at select")[1].select("30")

    click_link "学習時間追加"
    all(".learning-time")[1].all(".learning-time__started-at select")[0].select("08")
    all(".learning-time")[1].all(".learning-time__started-at select")[1].select("30")
    all(".learning-time")[1].all(".learning-time__finished-at select")[0].select("09")
    all(".learning-time")[1].all(".learning-time__finished-at select")[1].select("30")

    click_link "学習時間追加"
    all(".learning-time")[2].all(".learning-time__started-at select")[0].select("19")
    all(".learning-time")[2].all(".learning-time__started-at select")[1].select("30")
    all(".learning-time")[2].all(".learning-time__finished-at select")[0].select("20")
    all(".learning-time")[2].all(".learning-time__finished-at select")[1].select("15")

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

    all(".learning-time")[0].all(".learning-time__started-at select")[0].select("07")
    all(".learning-time")[0].all(".learning-time__started-at select")[1].select("30")
    all(".learning-time")[0].all(".learning-time__finished-at select")[0].select("08")
    all(".learning-time")[0].all(".learning-time__finished-at select")[1].select("30")

    click_link "学習時間追加"
    all(".learning-time")[1].all(".learning-time__started-at select")[0].select("08")
    all(".learning-time")[1].all(".learning-time__started-at select")[1].select("30")
    all(".learning-time")[1].all(".learning-time__finished-at select")[0].select("09")
    all(".learning-time")[1].all(".learning-time__finished-at select")[1].select("30")

    click_button "提出"

    assert_text "2時間\n"
    assert_text "07:30 〜 08:30"
    assert_text "08:30 〜 09:30"
  end

  test "register learning_times 1h40m" do
    visit "/reports/new"
    fill_in "report_title", with: "テスト日報 成功"
    fill_in "report_description", with: "不具合再現の結合テストコード"

    all(".learning-time")[0].all(".learning-time__started-at select")[0].select("07")
    all(".learning-time")[0].all(".learning-time__started-at select")[1].select("30")
    all(".learning-time")[0].all(".learning-time__finished-at select")[0].select("08")
    all(".learning-time")[0].all(".learning-time__finished-at select")[1].select("30")

    click_link "学習時間追加"
    all(".learning-time")[1].all(".learning-time__started-at select")[0].select("19")
    all(".learning-time")[1].all(".learning-time__started-at select")[1].select("30")
    all(".learning-time")[1].all(".learning-time__finished-at select")[0].select("20")
    all(".learning-time")[1].all(".learning-time__finished-at select")[1].select("15")

    click_button "提出"

    assert_text "1時間45分\n"
    assert_text "07:30 〜 08:30"
    assert_text "19:30 〜 20:15"
  end

  test "register learning_time 45m" do
    visit "/reports/new"
    fill_in "report_title", with: "テスト日報 成功"
    fill_in "report_description", with: "不具合再現の結合テストコード"

    all(".learning-time")[0].all(".learning-time__started-at select")[0].select("19")
    all(".learning-time")[0].all(".learning-time__started-at select")[1].select("30")
    all(".learning-time")[0].all(".learning-time__finished-at select")[0].select("20")
    all(".learning-time")[0].all(".learning-time__finished-at select")[1].select("15")

    click_button "提出"

    assert_text "45分\n"
    assert_text "19:30 〜 20:15"
  end

  test "register learning_times 1h" do
    visit "/reports/new"
    fill_in "report_title", with: "テスト日報"
    fill_in "report_description", with: "完了日時 - 開始日時 < 0のパターン"

    all(".learning-time")[0].all(".learning-time__started-at select")[0].select("23")
    all(".learning-time")[0].all(".learning-time__started-at select")[1].select("00")
    all(".learning-time")[0].all(".learning-time__finished-at select")[0].select("00")
    all(".learning-time")[0].all(".learning-time__finished-at select")[1].select("00")

    click_button "提出"

    assert_text "1時間\n"
    assert_text "23:00 〜 00:00"
  end

  test "register learning_times 4h" do
    visit "/reports/new"
    fill_in "report_title", with: "テスト日報"
    fill_in "report_description", with: "複数時間登録のパターン"

    all(".learning-time")[0].all(".learning-time__started-at select")[0].select("22")
    all(".learning-time")[0].all(".learning-time__started-at select")[1].select("00")
    all(".learning-time")[0].all(".learning-time__finished-at select")[0].select("00")
    all(".learning-time")[0].all(".learning-time__finished-at select")[1].select("00")

    click_link "学習時間追加"
    all(".learning-time")[1].all(".learning-time__started-at select")[0].select("00")
    all(".learning-time")[1].all(".learning-time__started-at select")[1].select("30")
    all(".learning-time")[1].all(".learning-time__finished-at select")[0].select("02")
    all(".learning-time")[1].all(".learning-time__finished-at select")[1].select("30")

    click_button "提出"

    assert_text "4時間\n"
    assert_text "22:00 〜 00:00"
    assert_text "00:30 〜 02:30"
  end

  test "can't register learning_times 0h0m" do
    visit "/reports/new"
    fill_in "report_title", with: "テスト日報"
    fill_in "report_description", with: "can't register learning_times 0h0m"

    all(".learning-time")[0].all(".learning-time__started-at select")[0].select("22")
    all(".learning-time")[0].all(".learning-time__started-at select")[1].select("00")
    all(".learning-time")[0].all(".learning-time__finished-at select")[0].select("22")
    all(".learning-time")[0].all(".learning-time__finished-at select")[1].select("00")

    click_button "提出"

    assert_text "終了時間は開始時間より後にしてください"
  end

  test "learning times order" do
    visit "/reports/new"
    fill_in "report_title", with: "テスト日報"
    fill_in "report_description", with: "学習時間の順番"

    all(".learning-time")[0].all(".learning-time__started-at select")[0].select("19")
    all(".learning-time")[0].all(".learning-time__started-at select")[1].select("30")
    all(".learning-time")[0].all(".learning-time__finished-at select")[0].select("20")
    all(".learning-time")[0].all(".learning-time__finished-at select")[1].select("15")

    click_link "学習時間追加"
    all(".learning-time")[1].all(".learning-time__started-at select")[0].select("07")
    all(".learning-time")[1].all(".learning-time__started-at select")[1].select("30")
    all(".learning-time")[1].all(".learning-time__finished-at select")[0].select("08")
    all(".learning-time")[1].all(".learning-time__finished-at select")[1].select("30")

    click_button "提出"
    assert_selector("ul.learning-times__items li.learning-times__item:nth-child(1)", text: "07:30 〜 08:30")
    assert_selector("ul.learning-times__items li.learning-times__item:nth-child(2)", text: "19:30 〜 20:15")
  end

  test "add learning times the next day" do
    visit "/reports/new"
    fill_in "report_title", with: "テスト日報"
    fill_in "report_description", with: "学習時間の順番"

    all(".learning-time")[0].all(".learning-time__started-at select")[0].select("19")
    all(".learning-time")[0].all(".learning-time__started-at select")[1].select("30")
    all(".learning-time")[0].all(".learning-time__finished-at select")[0].select("20")
    all(".learning-time")[0].all(".learning-time__finished-at select")[1].select("15")
    click_button "提出"

    travel 1.day

    click_link "内容修正"
    click_link "学習時間追加"
    all(".learning-time")[1].all(".learning-time__started-at select")[0].select("07")
    all(".learning-time")[1].all(".learning-time__started-at select")[1].select("30")
    all(".learning-time")[1].all(".learning-time__finished-at select")[0].select("08")
    all(".learning-time")[1].all(".learning-time__finished-at select")[1].select("30")
    click_button "内容変更"

    # Watchの非同期処理ための待ち時間
    sleep 0.5

    assert_selector("ul.learning-times__items li.learning-times__item:nth-child(1)", text: "07:30 〜 08:30")
    assert_selector("ul.learning-times__items li.learning-times__item:nth-child(2)", text: "19:30 〜 20:15")
  end

  test "reports can be copied" do
    user   = users(:komagata)
    report = user.reports.first
    visit report_path(report)
    travel 5.day do
      find("#copy").click
      assert_equal find("#report_reported_on").value, Date.current.strftime("%Y-%m-%d")
    end
  end

  test "previous report" do
    visit "/reports/#{reports(:report_2).id}"
    click_link "前の日報"
    assert_equal "/reports/#{reports(:report_1).id}", current_path
  end

  test "next report" do
    visit "/reports/#{reports(:report_2).id}"
    click_link "次の日報"
    assert_equal "/reports/#{reports(:report_3).id}", current_path
  end

  test "report has a comment form " do
    login_user "yamada", "testtest"
    visit "/reports/#{reports(:report_1).id}"
    assert_selector ".thread-comment-form"
  end

  test "unwatch" do
    login_user "kimura", "testtest"
    visit report_path(reports(:report_1))
    assert_difference("Watch.count", -1) do
      find("div.thread-header__watch-button", text: "Watch中").click
      sleep 0.5
    end
  end

  test "その日報を初めて提出した時にslackに通知がいく" do
    login_user "kensyu", "testtest"
    visit "/reports/new"
    within("#new_report") do
      fill_in("report[title]", with: "test title")
      fill_in("report[description]",   with: "test")
      fill_in("report[reported_on]", with: Time.current)
    end

    all(".learning-time")[0].all(".learning-time__started-at select")[0].select("07")
    all(".learning-time")[0].all(".learning-time__started-at select")[1].select("30")
    all(".learning-time")[0].all(".learning-time__finished-at select")[0].select("08")
    all(".learning-time")[0].all(".learning-time__finished-at select")[1].select("30")

    mock_log = []
    stub_info = Proc.new { |i| mock_log << i }

    Rails.logger.stub(:info, stub_info) do
      click_button "提出"
    end

    assert_text "日報を保存しました。"
    assert_text Time.current.strftime("%Y年%m月%d日")
    assert_match "kensyu さんが日報を提出しました", mock_log.to_s
  end

  test "WIPで保存した日報を初めて提出した時にだけslackに通知がいく" do
    login_user "kensyu", "testtest"
    visit "/reports/new"
    within("#new_report") do
      fill_in("report[title]", with: "test title")
      fill_in("report[description]",   with: "test")
      fill_in("report[reported_on]", with: Time.current)
    end

    all(".learning-time")[0].all(".learning-time__started-at select")[0].select("07")
    all(".learning-time")[0].all(".learning-time__started-at select")[1].select("30")
    all(".learning-time")[0].all(".learning-time__finished-at select")[0].select("08")
    all(".learning-time")[0].all(".learning-time__finished-at select")[1].select("30")

    mock_log = []
    stub_info = Proc.new { |i| mock_log << i }

    Rails.logger.stub(:info, stub_info) do
      click_button "WIP"
      assert_text "日報をWIPとして保存しました。"
      assert_no_match "kensyu さんが日報を提出しました", mock_log.to_s
      click_button "提出"
    end

    assert_text "日報を保存しました。"
    assert_text Time.current.strftime("%Y年%m月%d日")
    assert_match "kensyu さんが日報を提出しました", mock_log.to_s
  end

  test "最初の日報を提出した時にだけslackに通知がいく" do
    login_user "kensyu", "testtest"
    visit "/reports/new"
    within("#new_report") do
      fill_in("report[title]", with: "test title")
      fill_in("report[description]",   with: "test")
      fill_in("report[reported_on]", with: Time.current)
    end

    all(".learning-time")[0].all(".learning-time__started-at select")[0].select("07")
    all(".learning-time")[0].all(".learning-time__started-at select")[1].select("30")
    all(".learning-time")[0].all(".learning-time__finished-at select")[0].select("08")
    all(".learning-time")[0].all(".learning-time__finished-at select")[1].select("30")

    mock_log = []
    stub_info = Proc.new { |i| mock_log << i }

    Rails.logger.stub(:info, stub_info) do
      click_button "提出"
      assert_match "kensyu さんが日報を提出しました", mock_log.to_s
      mock_log = []
      click_link "内容修正"
      click_button "WIP"
      assert_text "日報をWIPとして保存しました。"
      assert_no_match "kensyu さんが日報を提出しました", mock_log.to_s
      click_button "提出"
    end

    assert_text "日報を保存しました。"
    assert_text Time.current.strftime("%Y年%m月%d日")
    assert_no_match "kensyu さんが日報を提出しました", mock_log.to_s
  end

  test "click unwatch" do
    login_user "kimura", "testtest"
    visit report_path(reports(:report_1))
    assert_difference("Watch.count", -1) do
      find("div.thread-header__watch-button", text: "Watch中").click
      sleep 0.5
    end
  end

  test "don't notify when first report is WIP" do
    Report.destroy_all

    login_user "kensyu", "testtest"
    visit "/reports/new"
    within("#new_report") do
      fill_in("report[title]", with: "test title")
      fill_in("report[description]", with: "test")
      fill_in("report[reported_on]", with: Time.current)
    end
    within(".learning-time__started-at") do
      select "07"
      select "30"
    end
    within(".learning-time__finished-at") do
      select "08"
      select "30"
    end

    click_button "WIP"
    assert_text "日報をWIPとして保存しました。"

    login_user "komagata", "testtest"
    visit "/notifications"
    assert_no_text "kensyuさんがはじめての日報を書きました！"
  end

  test "notify when WIP report submitted" do
    Report.all.each do |r|
      r.destroy
    end

    login_user "kensyu", "testtest"
    visit "/reports/new"
    within("#new_report") do
      fill_in("report[title]", with: "test title")
      fill_in("report[description]",   with: "test")
      fill_in("report[reported_on]", with: Time.current)
    end
    within(".learning-time__started-at") do
      select "07"
      select "30"
    end
    within(".learning-time__finished-at") do
      select "08"
      select "30"
    end

    click_button "WIP"
    assert_text "日報をWIPとして保存しました。"

    login_user "komagata", "testtest"
    visit "/notifications"
    assert_no_text "kensyuさんがはじめての日報を書きました！"

    login_user "kensyu", "testtest"
    visit "/users/#{users(:kensyu).id}/reports"
    click_link "test title"
    click_link "内容修正"
    click_button "提出"
    assert_text "日報を保存しました。"

    login_user "komagata", "testtest"
    visit "/notifications"
    assert_text "kensyuさんがはじめての日報を書きました！"
  end

  test "delete report with notification" do
    login_user "kimura", "testtest"
    visit "/reports/new"
    within("#new_report") do
      fill_in("report[title]", with: "test title")
      fill_in("report[description]",   with: "test")
      fill_in("report[reported_on]", with: Time.current)
    end
    within(".learning-time__started-at") do
      select "07"
      select "30"
    end
    within(".learning-time__finished-at") do
      select "08"
      select "30"
    end

    click_button "提出"
    assert_text "日報を保存しました。"

    login_user "komagata", "testtest"
    visit "/notifications"
    assert_text "kimuraさんがはじめての日報を書きました！"

    login_user "kimura", "testtest"
    visit "/reports"
    click_on "test title"
    accept_confirm do
      click_link "削除"
    end
    assert_text "日報を削除しました。"

    login_user "komagata", "testtest"
    visit "/notifications"
    assert_no_text "kimuraさんがはじめての日報を書きました！"
  end

  test "reports are ordered in descending of reported_on" do
    visit reports_path
    precede, succeed = reports(:report_2).title, reports(:report_1).title
    within ".thread-list" do
      assert page.text.index(precede) < page.text.index(succeed)
    end
  end

  test "reports are ordered in descending of created_at if reported_on is same" do
    visit reports_path
    precede, succeed = reports(:report_5).title, reports(:report_1).title
    within ".thread-list" do
      assert page.text.index(precede) < page.text.index(succeed)
    end
  end

  test "reports can be checked as plain markdown" do
    visit "/reports/new"
    within("#new_report") do
      fill_in("report[title]", with: "check plain markdown")
      fill_in("report[description]", with: "## this is heading2")
      fill_in("report[reported_on]", with: Time.current)
    end

    all(".learning-time")[0].all(".learning-time__started-at select")[0].select("07")
    all(".learning-time")[0].all(".learning-time__started-at select")[1].select("30")
    all(".learning-time")[0].all(".learning-time__finished-at select")[0].select("08")
    all(".learning-time")[0].all(".learning-time__finished-at select")[1].select("30")

    click_button "提出"
    click_link "Raw"
    switch_to_window windows.last
    assert_text "## this is heading2", exact: true
  end
end
