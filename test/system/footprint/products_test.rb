# frozen_string_literal: true

require "application_system_test_case"

class Footprint::ProductsTest < ApplicationSystemTestCase
  test "should be create footprint in product page" do
    login_user "komagata", "testtest"
    product = users(:yamada).products.first
    visit product_path(product)
    assert_text "見たよ"
    assert page.has_css?(".footprints-item__checker-icon.is-komagata")
  end

  test "should not footpoint with my own product" do
    login_user "yamada", "testtest"
    product = users(:yamada).products.first
    visit product_path(product)
    assert_no_text "見たよ"
    assert_not page.has_css?(".footprints-item__checker-icon.is-tanaka")
  end
end
