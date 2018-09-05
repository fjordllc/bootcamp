require "application_system_test_case"

class UserListTest < ApplicationSystemTestCase
  test "user list corresponding to selected status is displayed" do
    login_user "komagata", "testtest"

    assert_text "ユーザー"
    click_link "ユーザー"

    assert_equal 5, all(".tab-nav__item-link").length
    assert_equal 3, all(".users-item__inner").length
    assert_text "yamada"
    assert_text "kimura"
    assert_text "hatsuno"

    assert_text "メンター"
    click_link "メンター"
    assert_equal 2, all(".users-item__inner").length
    assert_text "komagata"
    assert_text "machida"

    assert_text "卒業生"
    click_link "卒業生"
    assert_equal 1, all(".users-item__inner").length
    assert_text "tanaka"

    assert_text "アドバイザー"
    click_link "アドバイザー"
    assert_equal 1, all(".users-item__inner").length
    assert_text "mineo"

    assert_text "全員"
    click_link "全員"
    assert_equal 8, all(".users-item__inner").length
    assert_text "yameo"
  end
end
