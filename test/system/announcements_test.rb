require "application_system_test_case"

class AnnouncementsTest < ApplicationSystemTestCase
  test "show link to create new announcement when user is admin" do
    login_user "komagata", "testtest"
    visit "/announcements"
    assert_text "お知らせの新規作成"
  end

  test "don't show link to create new announcement when user isn't admin" do
    login_user "yamada", "testtest"
    visit "/announcements"
    assert_no_text "お知らせの新規作成"
  end
end
