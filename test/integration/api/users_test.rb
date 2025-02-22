# frozen_string_literal: true

require 'test_helper'

class API::UsersTest < ActionDispatch::IntegrationTest
  fixtures :users

  def setup
    @application = Doorkeeper::Application.create!(
      name: 'Sample Application',
      redirect_uri: 'https://example.com/callback',
      scopes: 'read'
    )
  end

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

  test 'returns only authorized user information for admin user with doorkeeper token' do
    user = users(:komagata)
    doorkeeper_token = Doorkeeper::AccessToken.create!(
      application_id: @application.id,
      resource_owner_id: user.id,
      scopes: 'read'
    )
    get api_user_path(id: 'show'), headers: { Authorization: "Bearer #{doorkeeper_token.token}", Accept: 'application/json' }
    assert_response :ok

    response_body = JSON.parse(@response.body)
    authorized_keys = %w[id login_name email long_name url roles primary_role icon_title adviser avatar_url company]
    assert_equal authorized_keys.sort, response_body.keys.sort
  end

  test 'returns only authorized user information for authorized mentor with doorkeeper token' do
    user = users(:mentormentaro)
    doorkeeper_token = Doorkeeper::AccessToken.create!(
      application_id: @application.id,
      resource_owner_id: user.id,
      scopes: 'read'
    )
    get api_user_path(id: 'show'), headers: { Authorization: "Bearer #{doorkeeper_token.token}", Accept: 'application/json' }
    assert_response :ok

    response_body = JSON.parse(@response.body)
    authorized_keys = %w[id login_name email long_name url roles primary_role icon_title adviser avatar_url]
    assert_equal authorized_keys.sort, response_body.keys.sort
  end

  test 'returns only authorized user information for student with doorkeeper token' do
    user = users(:hatsuno)
    doorkeeper_token = Doorkeeper::AccessToken.create!(
      application_id: @application.id,
      resource_owner_id: user.id,
      scopes: 'read'
    )
    get api_user_path(id: 'show'), headers: { Authorization: "Bearer #{doorkeeper_token.token}", Accept: 'application/json' }
    assert_response :ok

    response_body = JSON.parse(@response.body)
    authorized_keys = %w[id login_name email long_name url roles primary_role icon_title adviser avatar_url]
    assert_equal authorized_keys.sort, response_body.keys.sort
  end

  test 'returns a 401 response when access an unauthorized API, even with a doorkeeper token' do
    user = users(:hatsuno)
    doorkeeper_token = Doorkeeper::AccessToken.create!(
      application_id: @application.id,
      resource_owner_id: user.id,
      scopes: 'read'
    )
    get api_admin_count_path(format: :json), headers: { Authorization: "Bearer #{doorkeeper_token.token}", Accept: 'application/json' }
    assert_response 401
  end
end
