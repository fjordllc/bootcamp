# frozen_string_literal: true

require 'test_helper'

class API::AnswersTest < ActionDispatch::IntegrationTest
  test 'GET /api/answers.json?user_id=253826460' do
    user = users(:hajime)
    get api_answers_path(user_id: user.id, format: :json)
    assert_response :unauthorized

    token = create_token('hajime', 'testtest')
    get api_answers_path(user_id: user.id, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end
end
