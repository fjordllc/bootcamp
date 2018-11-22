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
    login_user "mineo", "testtest"
    visit "/products/#{products(:product_1).id}"
    click_button "提出物を確認"
    assert_text "提出物を確認しました。"
  end
end
