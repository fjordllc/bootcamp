# frozen_string_literal: true

require "application_system_test_case"

class AnnouncementsTest < ApplicationSystemTestCase
  test "show link to create new announcement when user is admin" do
    login_user "komagata", "testtest"
    visit "/announcements"
    assert_text "お知らせ作成"
  end

  test "don't show link to create new announcement when user isn't admin" do
    login_user "kimura", "testtest"
    visit "/announcements"
    assert_no_text "お知らせ作成"
  end

  test "show pagination" do
    login_user "kimura", "testtest"
    user = users(:komagata)
    Announcement.delete_all
    26.times do |n|
      Announcement.create(title: "test", description: "test", user: user)
    end
    visit "/announcements"
    assert_selector "nav.pagination", count: 2
  end

  test "announcement has a comment form " do
    login_user "kimura", "testtest"
    visit "/announcements/#{announcements(:announcement_1).id}"
    assert_selector ".thread-comment-form"
  end
end
