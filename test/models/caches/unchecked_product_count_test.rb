# frozen_string_literal: true

require 'test_helper'

class UncheckedProductCountTest < ActiveSupport::TestCase
  setup do
    @original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
  end

  teardown do
    Rails.cache = @original_cache
  end

  test 'cached count of unchecked products increases by 1 after creating a product' do
    assert_difference 'Cache.unchecked_product_count', 1 do
      Product.create!(practice: practices(:practice5), user: users(:kimura), body: '未確認の提出物')
    end
  end

  test 'cached count of unchecked products decreases by 1 after destroying an unchecked product' do
    unchecked_product = Product.not_wip.unchecked.first

    assert_difference 'Cache.unchecked_product_count', -1 do
      unchecked_product.destroy!
    end
  end

  test 'cached count of unchecked products increases by 1 after unchecking a checked product' do
    check_of_checked_product = Product.checked.first.checks.first

    assert_difference 'Cache.unchecked_product_count', 1 do
      check_of_checked_product.destroy!
    end
  end

  test 'cached count of unchecked products decreases by 1 after checking an unchecked product' do
    unchecked_product = Product.not_wip.unchecked.first

    assert_difference 'Cache.unchecked_product_count', -1 do
      unchecked_product.checks.create!(user: users(:machida))
    end
  end

  test 'cached count of unchecked products is refreshed after deleting cache' do
    initial_count = Cache.unchecked_product_count

    # rubocop:disable Rails/SkipsModelValidations
    Product.insert_all!(
      [{
        practice_id: practices(:practice5).id,
        user_id: users(:kimura).id,
        body: '未確認の提出物',
        created_at: Time.current,
        updated_at: Time.current
      }]
    )
    # rubocop:enable Rails/SkipsModelValidations

    assert_equal initial_count, Cache.unchecked_product_count

    Cache.delete_unchecked_product_count

    assert_equal initial_count + 1, Cache.unchecked_product_count
  end
end
