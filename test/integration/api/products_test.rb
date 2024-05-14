# frozen_string_literal: true

require 'test_helper'

class API::ProductsTest < ActionDispatch::IntegrationTest
  test 'GET /api/products.json' do
    get api_products_path(format: :json)
    assert_response :unauthorized

    token = create_token('mentormentaro', 'testtest')
    get api_products_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'GET /api/products/unchecked.json' do
    get api_products_unchecked_index_path(format: :json)
    assert_response :unauthorized

    token = create_token('kimura', 'testtest')
    get api_products_unchecked_index_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :unauthorized

    token = create_token('mentormentaro', 'testtest')
    get api_products_unchecked_index_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'GET /api/products/unchecked.json?checker_id=534981761' do
    checker = users(:mentormentaro)
    get api_products_unchecked_index_path(checker_id: checker.id, format: :json)
    assert_response :unauthorized

    token = create_token('mentormentaro', 'testtest')
    get api_products_unchecked_index_path(checker_id: checker.id, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'GET /api/products/self_assigned.json' do
    get api_products_self_assigned_index_path(format: :json)
    assert_response :unauthorized

    token = create_token('kimura', 'testtest')
    get api_products_self_assigned_index_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :unauthorized

    token = create_token('mentormentaro', 'testtest')
    get api_products_self_assigned_index_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'should return products in order ' do
    token = create_token('machida', 'testtest')
    get api_products_self_assigned_index_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }

    expected = products(:product15, :product63, :product62, :product64).map { |product| product.practice.title }
    actual = response.parsed_body['products'].map { |product| product['practice']['title'] }
    assert_equal expected, actual
  end

  test 'GET /api/products.json?company_id=1022975240' do
    company = companies(:company4)
    get api_products_path(company_id: company.id, format: :json)
    assert_response :unauthorized

    token = create_token('kimura', 'testtest')
    get api_products_path(company_id: company.id, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'return correct number of products' do
    token = create_token('komagata', 'testtest')
    get api_products_unassigned_index_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }

    expected = products(:product8, :product10, :product11, :product12, :product13, :product14).map.count
    actual = response.parsed_body['products_grouped_by_elapsed_days'].find { |i| i['elapsed_days'] == 7 }['products'].count
    assert_equal expected, actual
  end
end
