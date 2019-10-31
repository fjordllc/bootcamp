# frozen_string_literal: true

require "application_system_test_case"

class Check::ProductsTest < ApplicationSystemTestCase
  test "user can see stamp" do
    login_user "sotugyou", "testtest"
    visit "/products/#{products(:product_3).id}"
    assert_text "確認済"
  end

  test "success product checking" do
    login_user "machida", "testtest"
    visit "/products/#{products(:product_1).id}"
    click_button "提出物を確認"
    assert_text "確認済"
    assert has_button? "提出物の確認を取り消す"
  end

  test "success adviser's product checking" do
    login_user "advijirou", "testtest"
    visit "/products/#{products(:product_1).id}"
    click_button "提出物を確認"
    assert_text "確認済"
    assert has_button? "提出物の確認を取り消す"
  end

  test "when product checked learning status to complete" do
    login_user "machida", "testtest"
    visit "/products/#{products(:product_1).id}"
    click_button "提出物を確認"
    assert_text "確認済"
    assert has_button? "提出物の確認を取り消す"

    login_user "yamada", "testtest"
    visit "/practices/#{products(:product_1).practice.id}"
    assert_equal first(".is-primary").text, "完了"
  end

  test "success product checking cancel" do
    login_user "machida", "testtest"
    visit "/products/#{products(:product_1).id}"
    click_button "提出物を確認"
    click_button "提出物の確認を取り消す"
    assert_no_text "確認済"
    assert has_button? "提出物を確認"
  end
end
