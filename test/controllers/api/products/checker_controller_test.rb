# frozen_string_literal: true

require 'test_helper'

class API::Products::CheckerControllerTest < ActionDispatch::IntegrationTest
  fixtures :products

  test 'PATCH /api/products/checker calls ProductCheckerNotifier' do
    product = products(:product15)
    product.update!(checker_id: nil)

    token = create_token('komagata', 'testtest')
    notifier = Minitest::Mock.new
    notifier.expect(:call, nil)

    ProductCheckerNotifier.stub(:new, lambda { |received_product, current_user|
      assert_equal product, received_product
      assert_equal users(:komagata), current_user
      notifier
    }) do
      patch api_products_checker_path,
            params: {
              product_id: product.id,
              current_user_id: users(:kimura).id
            },
            headers: { 'Authorization' => "Bearer #{token}" }
    end

    assert_response :ok
    notifier.verify
  end
end
