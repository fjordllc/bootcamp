# frozen_string_literal: true

require 'test_helper'

class API::Products::UnassignedTextTest < ActionDispatch::IntegrationTest
  fixtures :products

  test 'GET /api/products/unassigned/counts.txt' do
    products(:product15).update_column(:checker_id, nil)  # rubocop:disable Rails/SkipsModelValidations

    get counts_api_products_unassigned_index_path(format: :text)
    assert_response :unauthorized

    token = create_token('komagata', 'testtest')
    get counts_api_products_unassigned_index_path(format: :text),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok

    expected = <<~BODY
      - 7日以上経過：6件
      - 6日経過：2件
      - 5日経過：1件
    BODY
    assert response.body.include?(expected)
  end
end
