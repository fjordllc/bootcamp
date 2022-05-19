# frozen_string_literal: true

require 'test_helper'

class API::RegularEventsTest < ActionDispatch::IntegrationTest
  test 'GET /api/regular_events.json' do
    get api_regular_events_path(format: :json)
    assert_response :unauthorized

    token = create_token('hatsuno', 'testtest')
    get api_regular_events_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end
end
