# frozen_string_literal: true

require "application_system_test_case"

class Watch::ProductsTest < ApplicationSystemTestCase
  test "success product watching cancel" do
    setup do
      watches(:product1_watch_kimura)
    end

    login_user "kimura", "testtest"
    visit "/products/#{products(:product_1).id}"

    click_on "Unwatch"
    assert_text "ウォッチを止めました"
  end
end
