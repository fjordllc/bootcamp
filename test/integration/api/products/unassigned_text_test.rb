# frozen_string_literal: true

require 'test_helper'

class API::Products::UnassignedTextTest < ActionDispatch::IntegrationTest
  fixtures :products

  test 'GET /api/products/unassigned/text.txt' do
    get text_api_products_unassigned_index_path(format: :text)
    assert_response :unauthorized

    token = create_token('komagata', 'testtest')
    get text_api_products_unassigned_index_path(format: :text),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
    assert_match '5日経過：1件', response.body
    assert_match '6日経過：1件', response.body
    assert_match '7日以上経過：6件', response.body
  end
end
