# frozen_string_literal: true

require "application_system_test_case"

class Notification::ProductsTest < ApplicationSystemTestCase
  test "send adviser a notification when trainee create product" do
    login_user "kensyu", "testtest"
    visit "/products/new?practice_id=#{practices(:practice_5).id}"

    within("#new_product") do
      fill_in("product[body]", with: "test")
    end
    click_button "提出する"
    assert_text "提出物を作成しました。"

    logout
    login_user "senpai", "testtest"

    open_notification
    assert_equal "kensyuさんが「#{practices(:practice_5).title}」の提出物を提出しました。",
      notification_message
  end
end
