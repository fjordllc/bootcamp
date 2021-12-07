# frozen_string_literal: true

require 'test_helper'

class UncheckedProductCountTest < ActiveSupport::TestCase
  test 'increase the cached value of unchecked product count by 1 after create a product' do
    assert_difference 'Cache.unchecked_product_count', 1 do
      Product.create!(practice: practices(:practice5), user: users(:kimura), body: '未確認の提出物')
    end
  end

  test 'decreace the cached value of unchecked product count by 1 after destroy an unchecked product' do
    unchecked_product = Product.not_wip.unchecked.first

    assert_difference 'Cache.unchecked_product_count', -1 do
      unchecked_product.destroy!
    end
  end

  test 'increase the cached value of unchecked product count by 1 after uncheck a checked product' do
    check_of_checked_product = Product.checked.first.checks.first

    assert_difference 'Cache.unchecked_product_count', 1 do
      check_of_checked_product.destroy!
    end
  end

  test 'decrease the cached value of unchecked product count by 1 after check an unchecked product' do
    unchecked_product = Product.not_wip.unchecked.first

    assert_difference 'Cache.unchecked_product_count', -1 do
      unchecked_product.checks.create!(user: users(:machida))
    end
  end
end
