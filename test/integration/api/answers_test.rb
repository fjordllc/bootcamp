# frozen_string_literal: true

require 'test_helper'

class API::AnswersTest < ActionDispatch::IntegrationTest
  setup do
    @application = Doorkeeper::Application.create!(
      name: 'Sample Application',
      redirect_uri: 'urn:ietf:wg:oauth:2.0:oob'
    )
  end

  test 'GET /api/answers.json?user_id=253826460' do
    user = users(:hajime)
    get api_answers_path(user_id: user.id, format: :json)
    assert_response :unauthorized

    token = create_token('hajime', 'testtest')
    get api_answers_path(user_id: user.id, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'POST /api/answers.json with read scope returns forbidden' do
    token = Doorkeeper::AccessToken.create!(
      application: @application,
      resource_owner_id: users(:hajime).id,
      scopes: 'read'
    )

    post api_answers_path(format: :json),
         params: { question_id: questions(:question1).id, answer: { description: '回答します。' } },
         headers: { Authorization: "Bearer #{token.token}" }

    assert_response :forbidden
    assert_equal 'invalid_scope', response.parsed_body['error']
  end
end
