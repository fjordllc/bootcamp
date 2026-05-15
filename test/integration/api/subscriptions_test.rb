# frozen_string_literal: true

require 'test_helper'

class API::SubscriptionsTest < ActionDispatch::IntegrationTest
  test 'GET /api/subscriptions.json' do
    get api_subscriptions_path(format: :json)
    assert_response :unauthorized

    token = create_token('hatsuno', 'testtest')
    VCR.use_cassette 'subscription/all' do
      get api_subscriptions_path(format: :json),
          headers: { 'Authorization' => "Bearer #{token}" }
    end

    id = JSON.parse(@response.body)['subscriptions'][0]['id']
    assert_equal users(:hatsuno).subscription_id, id
  end
end
