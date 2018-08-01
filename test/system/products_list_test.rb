require "application_system_test_case"

class ProductsListTest < ApplicationSystemTestCase
  setup { login_user "tanaka", "testtest"}
  
  test "show products list when user's product is checked" do
    visit "/practices/#{practices(:practice_2).id}/products"
    click_link "提出物"
    assert_text "tanaka"
    assert_text "yamada"
    assert_text "kimura"
  end

  test "Don't show products list while user'product doesn't get checked yet" do
    visit "/practices/#{practices(:practice_3).id}/products"
    click_link "提出物"
    assert_text "tanaka"
    assert_no_text "yamada"
    assert_no_text "kimura"

  end

  test "Don't show products list when user don't upload product" do
    visit "/practices/#{practices(:practice_4).id}/products"
    click_link "提出物"
    assert_no_text "tanaka"
    assert_no_text "yamada"
    assert_no_text "kimura"
  end
end
