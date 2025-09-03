# frozen_string_literal: true

require 'test_helper'

class UncheckedNoRepliedProductsQueryTest < ActiveSupport::TestCase
  setup do
    @query = UncheckedNoRepliedProductsQuery.new
  end

  test 'should extracted as unchecked and no replied objects' do
    unchecked_no_replied_products = @query.call

    unchecked_no_replied_product = products(:product6)
    unchecked_only_self_replied_product = products(:product1)

    assert_includes unchecked_no_replied_products, unchecked_no_replied_product
    assert_includes unchecked_no_replied_products, unchecked_only_self_replied_product
  end

  test 'should not extracted as unchecked and no replied objects' do
    unchecked_no_replied_products = @query.call

    unchecked_replied_product = products(:product10)
    checked_product = products(:product2)

    assert_not_includes unchecked_no_replied_products, unchecked_replied_product
    assert_not_includes unchecked_no_replied_products, checked_product
  end
end
