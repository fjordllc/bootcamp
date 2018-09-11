require "application_system_test_case"

class ProductsTest < ApplicationSystemTestCase
  setup { login_user "yamada", "testtest" }

  test "show a product page" do
    visit "/practices/#{practices(:practice_1).id}/products/#{products(:product_1).id}"
    assert_equal "提出物 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "create a product" do
    visit "/practices/#{practices(:practice_5).id}/products/new"

    within("#new_product") do
      fill_in("product[body]", with: "test")
    end
    click_button "提出する"

    assert_text "提出物を作成しました。"
  end
end
