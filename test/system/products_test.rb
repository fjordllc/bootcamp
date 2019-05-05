# frozen_string_literal: true

require "application_system_test_case"

class ProductsTest < ApplicationSystemTestCase
  test "see my product" do
    login_user "yamada", "testtest"
    visit "/products/#{products(:product_1).id}"
    assert_equal "提出物 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "admin can see a product" do
    login_user "komagata", "testtest"
    visit "/products/#{products(:product_1).id}"
    assert_equal "提出物 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "adviser can see a product" do
    login_user "advijirou", "testtest"
    visit "/products/#{products(:product_1).id}"
    assert_equal "提出物 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "user who completed the practice can see the other user's product" do
    login_user "kimura", "testtest"
    visit "/products/#{products(:product_1).id}"
    assert_equal "提出物 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "can not see other user's product" do
    login_user "hatsuno", "testtest"
    visit "/products/#{products(:product_1).id}"
    assert_not_equal "提出物 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
    assert_text "プラクティスを完了するまで他の人の提出物は見れません。"
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

  test "update product" do
    login_user "yamada", "testtest"
    product = products(:product_1)
    visit "/products/#{product.id}/edit"
    within("form[name=product]") do
      fill_in("product[body]", with: "test")
    end
    click_button "提出する"
    assert_text "提出物を更新しました。"
  end

  test "delete product" do
    login_user "yamada", "testtest"
    product = products(:product_1)
    visit "/products/#{product.id}"
    accept_confirm do
      click_link "削除"
    end
    assert_text "提出物を削除しました。"
  end

  test "product has a comment form " do
    login_user "yamada", "testtest"
    visit "/products/#{products(:product_1).id}"
    assert_selector ".thread-comment-form"
  end

  test "admin can delete a product" do
    login_user "komagata", "testtest"
    product = products(:product_1)
    visit "/products/#{product.id}"
    accept_confirm do
      click_link "削除"
    end
    assert_text "提出物を削除しました。"
  end
end
