# frozen_string_literal: true

require 'test_helper'

class UnassignedProductCountTest < ActiveSupport::TestCase
  test 'cached count of unassigned products increases by 1 after creating a product' do
    assert_difference 'Cache.unassigned_product_count', 1 do
      Product.create!(practice: practices(:practice5), user: users(:kimura), body: 'test')
    end
  end

  test 'cached count of unassigned products decreases by 1 after destroying an unassigned product' do
    unassigned_product = Product.not_wip.unassigned.first

    assert_difference 'Cache.unassigned_product_count', -1 do
      unassigned_product.destroy!
    end
  end

  test 'cached count of unassigned products decreases by 1 after a mentor gets assigned to an unassigned product' do
    unassigned_product = Product.not_wip.unassigned.first

    assert_difference 'Cache.unassigned_product_count', -1 do
      unassigned_product.update!(checker_id: users(:machida).id)
    end
  end

  test 'cached count of unassigned products increases by 1 after a mentor gets unassigned from an assigned product' do
    assigned_product = Product.self_assigned_product(users(:machida).id).first

    assert_difference 'Cache.unassigned_product_count', 1 do
      assigned_product.update!(checker_id: nil)
    end
  end
end
