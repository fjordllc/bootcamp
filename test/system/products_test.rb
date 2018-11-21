# frozen_string_literal: true

require "application_system_test_case"

class ProductsTest < ApplicationSystemTestCase
  test "show product" do
    login_user "yamada", "testtest"
    visit "/products/#{products(:product_1).id}"
    assert_equal "提出物 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "create product" do
    login_user "yamada", "testtest"
    visit "/products/new?practice_id=#{practices(:practice_5).id}"
    within("#new_product") do
      fill_in("product[body]", with: "test")
    end
    click_button "提出する"
    assert_text "提出物を作成しました。"
  end
end
