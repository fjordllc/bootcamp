require "application_system_test_case"

class ProductsTest < ApplicationSystemTestCase
  setup { login_user "komagata", "testtest" }

  test "show a product page" do
    visit "/practices/#{practices(:practice_1).id}/products/#{products(:product_1).id}"
    assert_equal "提出物 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end
end
