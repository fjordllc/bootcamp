# frozen_string_literal: true

require 'test_helper'

class API::Practices::LearningControllerTest < ActionDispatch::IntegrationTest
  fixtures :practices, :products

  setup do
    Doorkeeper::Application.create!(
      name: 'Sample Application',
      redirect_uri: 'urn:ietf:wg:oauth:2.0:oob'
    )
  end

  test 'GET /api/practices/:practice_id/learning.json includes the product when one exists' do
    token = create_token('kimura', 'testtest')

    get api_practice_learning_path(practices(:practice1).id, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }

    assert_response :ok
    json = JSON.parse(response.body)
    assert_equal products(:product2).id, json.dig('practice', 'product', 'id')
  end

  test 'GET /api/practices/:practice_id/learning.json omits the product when none exists' do
    token = create_token('kimura', 'testtest')

    get api_practice_learning_path(practices(:practice7).id, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }

    assert_response :ok
    json = JSON.parse(response.body)
    assert_nil json['practice']['product']
  end
end
