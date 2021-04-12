# frozen_string_literal: true

require 'test_helper'

class API::PracticesTest < ActionDispatch::IntegrationTest
  fixtures :practices

  test 'GET /api/practices.json' do
    user = User.find_by(login_name: 'kimura')
    params = { user_id: user.id }
    get api_practices_path(format: :json)
    assert_response :unauthorized

    token = create_token(user.login_name, 'testtest')
    get api_practices_path(format: :json),
        params: params,
        headers: { 'Authorization' => "Bearer #{token}" }

    assert_response :ok
  end

  test 'GET /api/practices/1234.json' do
    get api_practice_path(practices(:practice1).id, format: :json)
    assert_response :unauthorized

    token = create_token('kimura', 'testtest')
    get api_practice_path(practices(:practice1).id, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :unauthorized

    token = create_token('yamada', 'testtest')
    get api_practice_path(practices(:practice1).id, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'PATCH /api/practices/1234.json' do
    patch api_practice_path(practices(:practice1).id, format: :json),
          params: { practice: { memo: 'test' } }
    assert_response :unauthorized

    token = create_token('kimura', 'testtest')
    patch api_practice_path(practices(:practice1).id, format: :json),
          params: { practice: { memo: 'test' } },
          headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :unauthorized

    token = create_token('yamada', 'testtest')
    patch api_practice_path(practices(:practice1).id, format: :json),
          params: { practice: { memo: 'test' } },
          headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end
end
