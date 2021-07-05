# frozen_string_literal: true

require 'test_helper'

class API::WatchesTest < ActionDispatch::IntegrationTest
  test 'GET /api/watches.json' do
    get api_watches_path(format: :json)
    assert_response :unauthorized

    token = create_token('kimura', 'testtest')
    get api_watches_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end
end
