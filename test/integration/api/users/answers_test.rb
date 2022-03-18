# frozen_string_literal: true

require 'test_helper'

class API::Users::AnswersTest < ActionDispatch::IntegrationTest
  test 'GET /api/users/253826460/answers.json' do
    user = users(:hajime)
    get api_user_answers_path(user_id: user.id, format: :json)
    assert_response :unauthorized

    token = create_token('hajime', 'testtest')
    get api_user_answers_path(user_id: user.id, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end
end
