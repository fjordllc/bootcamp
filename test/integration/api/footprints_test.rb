# frozen_string_literal: true

require 'test_helper'

class API::FootprintsTest < ActionDispatch::IntegrationTest
  fixtures :announcements

  setup do
    @announcement = announcements(:announcement1)
  end

  test 'GET /api/footprints.json?footprintable_id=@announcement.id' do
    get api_footprints_path(format: :json)
    assert_response :unauthorized

    token = create_token('machida', 'testtest')
    get api_footprints_path(format: :json, footprintable_id: @announcement.id),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :bad_request
  end
end
