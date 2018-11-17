# frozen_string_literal: true

require "application_system_test_case"

class Practice::ProductsTest < ApplicationSystemTestCase
  test "show listing products" do
    login_user "komagata", "testtest"
    visit "/practices/#{practices(:practice_1).id}/products"
    assert_equal "OS X Mountain Lionをクリーンインストールするの提出物 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "show products list when user's product is checked" do
    login_user "tanaka", "testtest"
    visit "/practices/#{practices(:practice_2).id}/products"
    click_link "提出物"
    assert_text "tanaka"
    assert_text "yamada"
    assert_text "kimura"
  end
end
