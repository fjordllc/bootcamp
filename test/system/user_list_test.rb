require "application_system_test_case"

class UserListTest < ApplicationSystemTestCase
  test "user list corresponding to selected status is displayed" do
    login_user "komagata", "testtest"

    assert_text "ユーザー"
    click_link "ユーザー"

    assert_equal all(".tab-nav__item-link").length, 5
    assert_equal all(".users-item__inner").length, 2
    assert_text "yamada"
    assert_text "kimura"

    assert_text "メンター"
    click_link "メンター"
    assert_equal all(".users-item__inner").length, 2
    assert_text "komagata"
    assert_text "machida"

    assert_text "卒業生"
    click_link "卒業生"
    assert_equal all(".users-item__inner").length, 1
    assert_text "tanaka"

    assert_text "アドバイザー"
    click_link "アドバイザー"
    assert_equal all(".users-item__inner").length, 1
    assert_text "mineo"

    assert_text "全員"
    click_link "全員"
    assert_equal all(".users-item__inner").length, 7
    assert_text "yameo"
  end
end
