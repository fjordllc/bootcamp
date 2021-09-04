# frozen_string_literal: true

require 'test_helper'

class API::EventsTest < ActionDispatch::IntegrationTest
  test 'GET /api/events.json' do
    get api_events_path(format: :json)
    assert_response :unauthorized

    token = create_token('kimura', 'testtest')
    get api_events_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end
end
