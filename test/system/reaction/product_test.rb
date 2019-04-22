# frozen_string_literal: true

require "application_system_test_case"

class Reaction::ProductsTest < ApplicationSystemTestCase
  setup { login_user "machida", "testtest" }

  test "show reaction of product" do
    visit product_path(products(:product_12))

    assert_text "🎉1\n👀1"
  end

  test "reaction to product" do
    visit product_path(products(:product_12))
    first(".thread__inner .js-reaction-dropdown-toggle").click
    first(".thread__inner .js-reaction-dropdown li[data-reaction-kind='smile']").click

    using_wait_time 5 do
      assert_text "😄1🎉1\n👀1"
    end
  end

  test "delete reaction of product on dropdown" do
    visit product_path(products(:product_12))
    first(".thread__inner .js-reaction-dropdown-toggle").click
    first(".thread__inner .js-reaction-dropdown li[data-reaction-kind='tada']").click

    using_wait_time 5 do
      assert_text "👀1"
    end
  end

  test "delete reaction of product on fotter" do
    visit product_path(products(:product_12))
    first(".thread__inner .js-reaction li[data-reaction-kind='tada']").click

    using_wait_time 5 do
      assert_text "👀1"
    end
  end
end
