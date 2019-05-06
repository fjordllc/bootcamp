# frozen_string_literal: true

require "application_system_test_case"

class Check::ProductsTest < ApplicationSystemTestCase
  test "success product checking" do
    login_user "machida", "testtest"
    visit "/products/#{products(:product_1).id}"
    click_button "提出物を確認"
    assert_text "提出物を確認しました。"
  end

  test "success adviser's product checking" do
    login_user "advijirou", "testtest"
    visit "/products/#{products(:product_1).id}"
    click_button "提出物を確認"
    assert_text "提出物を確認しました。"
  end

  test "success product checking cancel" do
    login_user "machida", "testtest"
    visit "/products/#{products(:product_1).id}"
    click_button "提出物を確認"
    click_button "提出物の確認を取り消す"
    assert_text "確認を取り消しました。"
  end
end
