# frozen_string_literal: true

require 'test_helper'

class UnassignedProductCountTest < ActiveSupport::TestCase
  setup do
    @original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
  end

  teardown do
    Rails.cache = @original_cache
  end

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

  test 'cached count of unassigned products is refreshed after deleting cache' do
    initial_count = Cache.unassigned_product_count

    # rubocop:disable Rails/SkipsModelValidations
    Product.insert_all!(
      [{
        practice_id: practices(:practice5).id,
        user_id: users(:kimura).id,
        body: 'test',
        created_at: Time.current,
        updated_at: Time.current
      }]
    )
    # rubocop:enable Rails/SkipsModelValidations

    assert_equal initial_count, Cache.unassigned_product_count

    Cache.delete_unassigned_product_count

    assert_equal initial_count + 1, Cache.unassigned_product_count
  end
end
