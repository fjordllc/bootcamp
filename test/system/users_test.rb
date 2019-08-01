# frozen_string_literal: true

require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  test "show profile" do
    login_user "hatsuno", "testtest"
    visit "/users/#{users(:hatsuno).id}"
    assert_equal "hatsunoのプロフィール | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "access by other users" do
    login_user "yamada", "testtest"
    user = users(:hatsuno)
    visit edit_admin_user_path(user.id)
    assert_text "管理者としてログインしてください"
  end

  test "retire user" do
    stub_subscription_destroy!

    login_user "hatsuno", "testtest"
    user = users(:hatsuno)
    visit new_retirement_path
    click_on "退会する"
    page.driver.browser.switch_to.alert.accept
    assert_text "退会処理が完了しました"
    assert_equal Date.current, user.reload.retired_on
    assert_equal "hatsunoさんが退会しました。", users(:komagata).notifications.last.message
    assert_equal "hatsunoさんが退会しました。", users(:machida).notifications.last.message

    login_user "hatsuno", "testtest"
    assert_text "ログインができません"
  end

  test "graduation date is displayed" do
    login_user "komagata", "testtest"

    visit "/users/#{users(:yamada).id}"
    assert_no_text "卒業日"

    visit "/users/#{users(:sotugyou).id}"
    assert_text "卒業日"
  end

  test "retired date is displayed" do
    login_user "komagata", "testtest"
    visit "/users/#{users(:yameo).id}"
    assert_text "リタイア日"
    visit "/users/#{users(:sotugyou).id}"
    assert_no_text "リタイア日"
  end

  test "normal user can't see unchecked number table" do
    login_user "hatsuno", "testtest"
    visit "/users/#{users(:hatsuno).id}"
    assert_equal 0, all(".admin-table").length
  end

  test "show users role" do
    login_user "komagata", "testtest"
    visit "/users/#{users(:komagata).id}"
    assert_text "管理者"

    login_user "yamada", "testtest"
    visit "/users/#{users(:yamada).id}"
    assert_text "メンター"

    login_user "advijirou", "testest"
    visit "/users/#{users(:advijirou).id}"
    assert_text "アドバイザー"

    login_user "kensyu", "testtest"
    visit "/users/#{users(:kensyu).id}"
    assert_text "研修生"

    login_user "sotugyou", "testtest"
    visit "/users/#{users(:sotugyou)}"
    assert_text "卒業生"
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
    assert_text "提出物を作成しました。"
    visit edit_current_user_path
    click_on "退会手続きへ進む"
    fill_in "user[retire_reason]", with: "辞" * 8
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
    fill_in "user[retire_reason]", with: "辞" * 8
    assert_difference "user.reports.wip.count", -1 do
      page.accept_confirm "本当によろしいですか？" do
        click_on "退会する"
      end
      assert_text "退会処理が完了しました"
    end
  end
end
