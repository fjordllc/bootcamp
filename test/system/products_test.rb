# frozen_string_literal: true

require "application_system_test_case"

class ProductsTest < ApplicationSystemTestCase
  test "show a product page" do
    login_user "yamada", "testtest"

    visit "/products/#{products(:product_1).id}"
    assert_equal "提出物 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "create a product" do
    login_user "yamada", "testtest"
    visit "/products/new?practice_id=#{practices(:practice_5).id}"

    within("#new_product") do
      fill_in("product[body]", with: "test")
    end
    click_button "提出する"

    assert_text "提出物を作成しました。"
  end

  test "show products list when user's product is checked" do
    login_user "tanaka", "testtest"

    visit "/practices/#{practices(:practice_2).id}/products"
    click_link "提出物"
    assert_text "tanaka"
    assert_text "yamada"
    assert_text "kimura"
  end

  test "Don't show 提出物tab while user'product doesn't get checked yet" do
    login_user "tanaka", "testtest"

    visit "/practices/#{practices(:practice_3).id}/products"
    assert_no_text "提出物"
  end

  test "Don't 提出物tab list when user don't upload product" do
    login_user "tanaka", "testtest"

    visit "/practices/#{practices(:practice_4).id}/products"
    assert_no_text "提出物"
  end
end
