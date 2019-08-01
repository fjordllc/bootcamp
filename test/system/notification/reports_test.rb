# frozen_string_literal: true

require "application_system_test_case"

class Notification::ReportsTest < ApplicationSystemTestCase
  test "はじめての日報が投稿されたときに全員が通知を受け取る" do
    login_user "muryou", "testtest"
    visit "/reports"
    click_link "日報作成"

    within("#new_report") do
      fill_in("report[title]", with: "test title")
      fill_in("report[description]",   with: "test")
    end

    all(".learning-time")[0].all(".learning-time__started-at select")[0].select("07")
    all(".learning-time")[0].all(".learning-time__started-at select")[1].select("30")
    all(".learning-time")[0].all(".learning-time__finished-at select")[0].select("08")
    all(".learning-time")[0].all(".learning-time__finished-at select")[1].select("30")

    click_button "提出"
    logout

    login_user "komagata", "testtest"
    first(".test-bell").click
    assert_text "muryouさんがはじめての日報を書きました！"
    logout

    login_user "yamada", "testtest"
    first(".test-bell").click
    assert_text "muryouさんがはじめての日報を書きました！"
    logout
  end

  test "複数の日報が投稿されているときは通知が飛ばない" do
    login_user "komagata", "testtest"
    visit "/reports"
    click_link "日報作成"

    within("#new_report") do
      fill_in("report[title]", with: "test title")
      fill_in("report[description]",   with: "test")
    end

    all(".learning-time")[0].all(".learning-time__started-at select")[0].select("07")
    all(".learning-time")[0].all(".learning-time__started-at select")[1].select("30")
    all(".learning-time")[0].all(".learning-time__finished-at select")[0].select("08")
    all(".learning-time")[0].all(".learning-time__finished-at select")[1].select("30")

    click_button "提出"
    logout

    login_user "muryou", "testtest"
    assert page.has_css?(".has-no-count")
    logout

    login_user "yamada", "testtest"
    assert page.has_css?(".has-no-count")
    logout
  end

  test "研修生が日報を提出したら企業のアドバイザーに通知が飛ぶ" do
    login_user "kensyu", "testtest"
    visit "/reports/new"
    within("#new_report") do
      fill_in("report[title]", with: "test title")
      fill_in("report[description]",   with: "test")
    end

    all(".learning-time")[0].all(".learning-time__started-at select")[0].select("07")
    all(".learning-time")[0].all(".learning-time__started-at select")[1].select("30")
    all(".learning-time")[0].all(".learning-time__finished-at select")[0].select("08")
    all(".learning-time")[0].all(".learning-time__finished-at select")[1].select("30")
    click_button "提出"

    logout

    login_user "senpai", "testtest"
    first(".test-bell").click
    assert_text "kensyuさんが日報【 test title 】を書きました！"
  end
end
