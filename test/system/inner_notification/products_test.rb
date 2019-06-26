# frozen_string_literal: true

require "application_system_test_case"

class InnerNotification::ProductsTest < ApplicationSystemTestCase
  test "recieve a notification when product is created" do
    login_user "yamada", "testtest"
    visit "/products/new?practice_id=#{practices(:practice_5).id}"

    within("#new_product") do
      fill_in("product[body]", with: "test")
    end
    click_button "提出する"
    assert_text "提出物を作成しました。"

    logout
    login_user "komagata", "testtest"

    first(".test-bell").click
    assert_text "yamadaさんが提出しました。"

    # 提出物を作成したとき、管理者からウォッチがつく
    click_link  "yamadaさんが提出しました。"
    assert_text "Watch中"
  end

  test "recieve a notification when product is updated" do
    login_user "yamada", "testtest"
    visit "/products/#{products(:product_1).id}/edit"
    within("#edit_product_#{products(:product_1).id}") do
      fill_in("product[body]", with: "test")
    end
    click_button "提出する"
    assert_text "提出物を更新しました。"

    logout
    login_user "komagata", "testtest"

    first(".test-bell").click
    assert_text "yamadaさんが提出物を更新しました。"
  end

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

    first(".test-bell").click
    assert_text "kensyuさんが提出しました。"
  end
end
