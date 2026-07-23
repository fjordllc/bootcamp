# frozen_string_literal: true

require 'test_helper'

class API::ProductsTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:kimura)
    application = Doorkeeper::Application.create!(
      name: 'Sample Application',
      redirect_uri: 'urn:ietf:wg:oauth:2.0:oob'
    )
    @read_token = Doorkeeper::AccessToken.create!(
      application:,
      resource_owner_id: @user.id,
      scopes: 'read'
    )
    @write_token = Doorkeeper::AccessToken.create!(
      application:,
      resource_owner_id: @user.id,
      scopes: 'read write'
    )
  end

  test 'GET /api/products.json' do
    get api_products_path(format: :json)
    assert_response :unauthorized

    token = create_token('mentormentaro', 'testtest')
    get api_products_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'GET /api/products/:id.json returns body' do
    product = products(:product1)

    token = create_token('mentormentaro', 'testtest')

    get api_product_path(product, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }

    assert_response :ok
    assert_equal product.body, response.parsed_body['body']
  end

  test 'GET /api/products/:id.json returns check list' do
    product = products(:product2)

    token = create_token('mentormentaro', 'testtest')

    get api_product_path(product, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }

    assert_response :ok

    json = JSON.parse(response.body)

    check = checks(:product2_check_komagata)

    assert_equal check.id, json['checks']['list'][0]['id']
    assert_equal 'komagata', json['checks']['list'][0]['user']['login_name']
    assert_equal check.created_at.as_json, json['checks']['list'][0]['created_at']
  end

  test 'returns json error with invalid token' do
    get api_products_path(format: :json),
        headers: { Authorization: 'Bearer invalid-token' }

    assert_response :unauthorized
    assert_equal 'unauthorized', response.parsed_body['error']
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

  test 'GET /api/products/unchecked.json?target=unchecked_no_replied' do
    get api_products_unchecked_index_path(target: 'unchecked_no_replied', format: :json)
    assert_response :unauthorized

    token = create_token('mentormentaro', 'testtest')
    get api_products_unchecked_index_path(target: 'unchecked_no_replied', format: :json),
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

    expected = products(:product15, :product62, :product64, :product63).map { |product| product.practice.title }
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

  test 'can create product with write scope' do
    practice = first_unsubmitted_practice(@user)

    assert_difference('Product.count') do
      post api_products_path(format: :json),
           headers: { Authorization: "Bearer #{@write_token.token}" },
           params: { product: { practice_id: practice.id, body: 'APIから提出します。', wip: false } }
      assert_response :created
    end

    product = Product.find(response.parsed_body['id'])
    assert_equal @user, product.user
    assert_equal practice, product.practice
    assert_equal 'APIから提出します。', product.body
    assert_not product.wip
    assert_not_nil product.published_at
    assert_equal product.body, response.parsed_body['body']
    assert_equal practice.id, response.parsed_body['practice_id']
  end

  test 'enqueues Pjord product review when creating submitted product with write scope' do
    practice = first_unsubmitted_practice(@user)

    assert_enqueued_with(job: PjordProductReviewJob) do
      post api_products_path(format: :json),
           headers: { Authorization: "Bearer #{@write_token.token}" },
           params: { product: { practice_id: practice.id, body: 'APIから提出します。', wip: false } }
    end
  end

  test 'can update own product with write scope' do
    product = products(:product8)

    patch api_product_path(product, format: :json),
          headers: { Authorization: "Bearer #{@write_token.token}" },
          params: { product: { body: 'APIからWIP更新します。', wip: true } }

    assert_response :ok
    product.reload
    assert_equal 'APIからWIP更新します。', product.body
    assert product.wip
    assert_nil product.published_at
    assert_equal product.body, response.parsed_body['body']
    assert response.parsed_body['wip']
  end

  test 'enqueues Pjord product review when updating WIP product to submitted with write scope' do
    product = products(:product5)

    assert_enqueued_with(job: PjordProductReviewJob, args: [{ product_id: product.id }]) do
      patch api_product_path(product, format: :json),
            headers: { Authorization: "Bearer #{@write_token.token}" },
            params: { product: { body: 'APIから提出します。', wip: false } }
    end
  end

  test 'does not enqueue Pjord product review when updating submitted product with write scope' do
    product = products(:product8)

    assert_no_enqueued_jobs only: PjordProductReviewJob do
      patch api_product_path(product, format: :json),
            headers: { Authorization: "Bearer #{@write_token.token}" },
            params: { product: { body: 'APIから更新します。', wip: false } }
    end
  end

  test 'can delete own product with write scope' do
    product = products(:product8)

    assert_difference('Product.count', -1) do
      delete api_product_path(product, format: :json),
             headers: { Authorization: "Bearer #{@write_token.token}" }
      assert_response :no_content
    end
  end

  test 'can not create product with read scope' do
    practice = first_unsubmitted_practice(@user)

    post api_products_path(format: :json),
         headers: { Authorization: "Bearer #{@read_token.token}" },
         params: { product: { practice_id: practice.id, body: 'APIから提出します。', wip: false } }

    assert_response :forbidden
    assert_equal 'invalid_scope', response.parsed_body['error']
  end

  test 'can not update product with read scope' do
    product = products(:product8)

    patch api_product_path(product, format: :json),
          headers: { Authorization: "Bearer #{@read_token.token}" },
          params: { product: { body: 'APIから更新します。' } }

    assert_response :forbidden
    assert_equal 'invalid_scope', response.parsed_body['error']
  end

  test 'can not delete product with read scope' do
    product = products(:product8)

    assert_no_difference('Product.count') do
      delete api_product_path(product, format: :json),
             headers: { Authorization: "Bearer #{@read_token.token}" }
    end

    assert_response :forbidden
    assert_equal 'invalid_scope', response.parsed_body['error']
  end

  test 'returns validation error when creating invalid product' do
    practice = first_unsubmitted_practice(@user)

    assert_no_difference('Product.count') do
      post api_products_path(format: :json),
           headers: { Authorization: "Bearer #{@write_token.token}" },
           params: { product: { practice_id: practice.id, body: '', wip: false } }
    end

    assert_response :unprocessable_entity
    assert response.parsed_body.dig('errors', 'body').present?
  end

  test 'returns bad request when updating product practice' do
    product = products(:product8)

    patch api_product_path(product, format: :json),
          headers: { Authorization: "Bearer #{@write_token.token}" },
          params: { product: { practice_id: practices(:practice1).id } }

    assert_response :bad_request
    assert_equal '提出物のプラクティスは変更できません。', response.parsed_body['message']
  end

  test 'returns permission error when updating another user product' do
    product = products(:product11)

    patch api_product_path(product, format: :json),
          headers: { Authorization: "Bearer #{@write_token.token}" },
          params: { product: { body: '他人の提出物を更新します。' } }

    assert_response :forbidden
    assert_equal 'この提出物を操作する権限がありません。', response.parsed_body['message']
  end

  test 'returns permission error when deleting another user product' do
    product = products(:product11)

    assert_no_difference('Product.count') do
      delete api_product_path(product, format: :json),
             headers: { Authorization: "Bearer #{@write_token.token}" }
    end

    assert_response :forbidden
    assert_equal 'この提出物を操作する権限がありません。', response.parsed_body['message']
  end

  test 'mentor can update another user product with write scope' do
    product = products(:product8)
    mentor_token = Doorkeeper::AccessToken.create!(
      application: @write_token.application,
      resource_owner_id: users(:mentormentaro).id,
      scopes: 'read write'
    )

    patch api_product_path(product, format: :json),
          headers: { Authorization: "Bearer #{mentor_token.token}" },
          params: { product: { body: 'メンターがAPIから更新します。' } }

    assert_response :ok
    assert_equal 'メンターがAPIから更新します。', product.reload.body
  end

  test 'GET /api/products/:id.json returns practice information' do
    token = create_token('mentormentaro', 'testtest')

    product = products(:product1)

    get api_product_path(product, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }

    assert_response :ok

    json = JSON.parse(response.body)

    assert_equal product.practice.id, json['practice']['id']
    assert_equal product.practice.title, json['practice']['title']
    assert_equal product.practice.description, json['practice']['description']
  end

  private

  def first_unsubmitted_practice(user)
    Practice.where.not(id: user.products.select(:practice_id)).order(:id).first
  end
end
