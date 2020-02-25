# frozen_string_literal: true

require "application_system_test_case"

class Notification::EventsTest < ApplicationSystemTestCase
  test "waiting user receive notification when the event participant cancel" do
    event = events(:event_3)
    login_user "komagata", "testtest"
    visit event_path(event)
    accept_confirm do
      click_link "キャンセル"
    end
    logout

    login_user "hatsuno", "testtest"
    first(".test-bell").click
    assert_text "#{event.title}で、補欠から参加に繰り上がりました。"
    logout
  end

  test "waiting user receive notification when the event capacity is increased" do
    event = events(:event_3)
    login_user "komagata", "testtest"
    visit event_path(event)
    click_link "内容修正"

    fill_in "event_capacity", with: 2
    click_button "内容変更"
    logout

    login_user "hatsuno", "testtest"
    first(".test-bell").click
    assert_text "#{event.title}で、補欠から参加に繰り上がりました。"
    logout
  end
end
