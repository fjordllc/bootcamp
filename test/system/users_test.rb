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

  test "retire reason is displayed when login user is admin" do
    login_user "komagata", "testtest"
    visit "/users/#{users(:yameo).id}"
    assert_text "退会理由"
    visit "/users/#{users(:sotugyou).id}"
    assert_no_text "退会理由"
  end

  test "retire reason isn't displayed when login user isn't admin" do
    login_user "kimura", "testtest"
    visit "/users/#{users(:yameo).id}"
    assert_no_text "退会理由"
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

  test "show completed practices" do
    login_user "machida", "testtest"
    visit "/users/#{users(:kimura).id}"
    assert_text "OS X Mountain Lionをクリーンインストールする"
    assert_no_text "Terminalの基礎を覚える"
  end

  test "show my seat today" do
    login_user "hajime", "testtest"
    visit "/"
    assert_text "今日はF席を予約しています"

    login_user "kimura", "testtest"
    visit "/"
    assert_text "今日はE席を予約しています"

    login_user "kensyu", "testtest"
    visit "/"
    assert_no_text "予約しています"
  end

  test "show last active date only to mentors" do
    travel_to Time.new(2014, 1, 1, 0, 0, 0) do
      login_user "kimura", "testtest"
    end

    login_user "komagata", "testtest"

    visit "/users/#{users(:kimura).id}"
    assert_text "最終ログイン日時"
    assert_selector "div.user-metas__item-value.is-important"

    visit "/users/#{users(:komagata).id}"
    assert_text "最終ログイン日時"
    assert_no_selector "div.user-metas__item-value.is-important"

    login_user "hatsuno", "testtest"
    visit "/users/#{users(:hatsuno).id}"
    assert_no_text "最終ログイン日時"
  end

  test "show inactive message on users page" do
    travel_to Time.new(2014, 1, 1, 0, 0, 0) do
      login_user "kimura", "testtest"
    end

    login_user "komagata", "testtest"
    visit "/users"
    assert_no_selector "div.users-item.inactive"
    assert_text "1ヶ月ログインがありません"

    login_user "hatsuno", "testtest"
    visit "/users"
    assert_no_selector "div.users-item.inactive"
    assert_no_text "1ヶ月ログインがありません"
  end
end
