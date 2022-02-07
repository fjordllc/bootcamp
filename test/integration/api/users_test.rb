# frozen_string_literal: true

require 'test_helper'

class API::UsersTest < ActionDispatch::IntegrationTest
  fixtures :users

  test 'GET /api/users.json' do
    get api_users_path(format: :json)
    assert_response :unauthorized

    token = create_token('kimura', 'testtest')
    get api_users_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'GET /api/users/1234.json as admin' do
    get api_users_path(users(:kimura).id, format: :json)
    assert_response :unauthorized

    token = create_token('komagata', 'testtest')
    get api_user_path(users(:kimura).id, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
    assert_equal(users(:kimura).mentor_memo, JSON.parse(@response.body)['mentor_memo'])
  end

  test 'GET /api/users/1234.json as mentor' do
    get api_users_path(users(:kimura).id, format: :json)
    assert_response :unauthorized

    token = create_token('mentormentaro', 'testtest')
    get api_user_path(users(:kimura).id, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
    assert_equal(users(:kimura).mentor_memo, JSON.parse(@response.body)['mentor_memo'])
  end

  test 'GET /api/users/1234.json as adviser' do
    get api_users_path(users(:kimura).id, format: :json)
    assert_response :unauthorized

    token = create_token('advijirou', 'testtest')
    get api_user_path(users(:kimura).id, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
    assert_nil(JSON.parse(@response.body)['mentor_memo'])
  end

  test 'GET /api/users/1234.json as trainee' do
    get api_users_path(users(:kimura).id, format: :json)
    assert_response :unauthorized

    token = create_token('kensyu', 'testtest')
    get api_user_path(users(:kimura).id, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
    assert_nil(JSON.parse(@response.body)['mentor_memo'])
  end

  test 'GET /api/users/1234.json as graduate' do
    get api_users_path(users(:kimura).id, format: :json)
    assert_response :unauthorized

    token = create_token('sotugyou', 'testtest')
    get api_user_path(users(:kimura).id, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
    assert_nil(JSON.parse(@response.body)['mentor_memo'])
  end

  test 'GET /api/users/1234.json as student' do
    get api_users_path(users(:kimura).id, format: :json)
    assert_response :unauthorized

    token = create_token('kimura', 'testtest')
    get api_user_path(users(:kimura).id, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
    assert_nil(JSON.parse(@response.body)['mentor_memo'])
  end
end
