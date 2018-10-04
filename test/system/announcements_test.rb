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

  test "show pagination" do
    user = users(:komagata)
    Announcement.delete_all
    26.times do |n|
      Announcement.create(title: "test", description: "test", user: user)
    end
    visit "/announcements"
    assert_selector "nav.pagination", count: 2
  end
end
