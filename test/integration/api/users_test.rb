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

  test 'GET /api/users/1234.json as student' do
    get api_users_path(users(:kimura).id, format: :json)
    assert_response :unauthorized

    token = create_token('kimura', 'testtest')
    get api_user_path(users(:kimura).id, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
    assert_nil(JSON.parse(@response.body)['memo'])
  end

  test 'GET /api/users/1234.json as mentor' do
    get api_users_path(users(:kimura).id, format: :json)
    assert_response :unauthorized

    token = create_token('komagata', 'testtest')
    get api_user_path(users(:kimura).id, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
    assert_equal(users(:kimura).memo, JSON.parse(@response.body)['memo'])
  end
end
