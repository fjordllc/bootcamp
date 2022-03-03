# frozen_string_literal: true

require 'test_helper'

class API::Users::QuestionsTest < ActionDispatch::IntegrationTest
  test 'GET /api/users/253826460/questions.json' do
    @user = users(:hajime)
    get api_user_questions_path(@user.id, format: :json)
    assert_response :unauthorized

    token = create_token('hajime', 'testtest')
    get api_user_questions_path(@user.id, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end
end
