# frozen_string_literal: true

require 'application_system_test_case'

class Reaction::ProductsTest < ApplicationSystemTestCase
  test 'show reaction of product' do
    visit_with_auth product_path(products(:product12)), 'machida'

    assert_text "🎉1\n👀1"
  end

  test 'reaction to product' do
    visit_with_auth product_path(products(:product12)), 'machida'
    first('.js-reaction-dropdown-toggle').click
    first(".js-reaction-dropdown li[data-reaction-kind='eyes']").click

    using_wait_time 5 do
      assert_text "🎉1\n👀2"
    end
  end

  test 'delete reaction of product on dropdown' do
    visit_with_auth product_path(products(:product12)), 'machida'
    first('.js-reaction-dropdown-toggle').click
    first(".js-reaction-dropdown li[data-reaction-kind='tada']").click

    using_wait_time 5 do
      assert_text '👀1'
    end
  end

  test 'delete reaction of product on fotter' do
    visit_with_auth product_path(products(:product12)), 'machida'
    first(".js-reaction li[data-reaction-kind='tada']").click

    using_wait_time 5 do
      assert_text '👀1'
    end
  end
end
