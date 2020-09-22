# frozen_string_literal: true

require "application_system_test_case"

class RetirementTest < ApplicationSystemTestCase
  test "retire user" do
    stub_subscription_destroy!

    login_user "kananashi", "testtest"
    user = users(:kananashi)
    visit new_retirement_path
    choose "良い", visible: false
    click_on "退会する"
    page.driver.browser.switch_to.alert.accept
    assert_text "退会処理が完了しました"
    assert_equal Date.current, user.reload.retired_on
    assert_equal "kananashiさんが退会しました。", users(:komagata).notifications.last.message
    assert_equal "kananashiさんが退会しました。", users(:machida).notifications.last.message

    login_user "kananashi", "testtest"
    assert_text "ログインができません"

    login_user "osnashi", "testtest"
    user = users(:osnashi)
    visit new_retirement_path
    choose "良い", visible: false
    click_on "退会する"
    page.driver.browser.switch_to.alert.accept
    assert_text "退会処理が完了しました"
    assert_equal Date.current, user.reload.retired_on
    assert_equal "osnashiさんが退会しました。", users(:komagata).notifications.last.message
    assert_equal "osnashiさんが退会しました。", users(:machida).notifications.last.message

    login_user "osnashi", "testtest"
    assert_text "ログインができません"
  end

  test "delete unchecked products when the user retired" do
    stub_subscription_cancel!

    login_user "muryou", "testtest"
    user = users(:muryou)
    visit "/products/new?practice_id=#{practices(:practice_5).id}"
    within("#new_product") do
      fill_in("product[body]", with: "test")
    end
    click_button "提出する"
    assert_text "提出物を提出しました。7日以内にメンターがレビューしますので、次のプラクティスにお進みください。\n7日以上待ってもレビューされない場合は、気軽にメンターにメンションを送ってください。"
    visit edit_current_user_path
    click_on "退会手続きへ進む"
    check "受講したいカリキュラムを全て受講したから", allow_label_click: true
    fill_in "user[retire_reason]", with: "辞" * 8
    choose "良い", visible: false
    fill_in "user[opinion]", with: "ご意見"
    assert_difference "user.products.unchecked.count", -1 do
      page.accept_confirm "本当によろしいですか？" do
        click_on "退会する"
      end
      assert_text "退会処理が完了しました"
    end
  end

  test "delete WIP reports when the user retired" do
    stub_subscription_cancel!

    login_user "muryou", "testtest"
    user = users(:muryou)
    visit "/reports/new"
    within("#new_report") do
      fill_in("report[title]", with: "test title")
      fill_in("report[description]",   with: "test")
    end
    click_button "WIP"
    assert_text "日報をWIPとして保存しました。"
    visit edit_current_user_path
    click_on "退会手続きへ進む"
    check "受講したいカリキュラムを全て受講したから", allow_label_click: true
    fill_in "user[retire_reason]", with: "辞" * 8
    choose "良い", visible: false
    fill_in "user[opinion]", with: "ご意見"
    assert_difference "user.reports.wip.count", -1 do
      page.accept_confirm "本当によろしいですか？" do
        click_on "退会する"
      end
      assert_text "退会処理が完了しました"
    end
  end
end
