# frozen_string_literal: true

require 'test_helper'

class Api::Products::UnassignedTextTest < ActionDispatch::IntegrationTest
  fixtures :products

  test 'GET /api/products/unassigned/counts.txt' do
    products(:product15).update_column(:checker_id, nil) # rubocop:disable Rails/SkipsModelValidations

    get counts_api_products_unassigned_index_path(format: :text)
    assert_response :unauthorized

    token = create_token('komagata', 'testtest')
    get counts_api_products_unassigned_index_path(format: :text),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok

    expected = <<~BODY
      - 6日以上経過：8件
      - 5日経過：1件
      - 4日経過：1件
    BODY
    assert_includes response.body, expected
  end
end
