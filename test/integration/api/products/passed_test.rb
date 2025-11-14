# frozen_string_literal: true

require 'test_helper'

class Api::Products::PassedTest < ActionDispatch::IntegrationTest
  fixtures :products

  test 'GET /api/products/passed.json' do
    products(:product15).update!(checker_id: nil)

    get api_products_passed_path(format: :text)
    assert_response :unauthorized

    token = create_token('komagata', 'testtest')
    get api_products_passed_path(format: :text),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok

    expected = <<~BODY
      - 4日経過：1件
      - 5日経過：1件
      - 6日以上経過：8件
    BODY
    assert_includes response.body, expected
  end
end
