# frozen_string_literal: true

require 'test_helper'

class API::FootprintsTest < ActionDispatch::IntegrationTest
  test 'GET /api/footprints.json?footprintable_id=12168338' do
    get api_footprints_path(format: :json)
    assert_response :unauthorized

    token = create_token('machida', 'testtest')
    get api_footprints_path(format: :json, footprintable_id: 12_168_338),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :bad_request
  end
end
