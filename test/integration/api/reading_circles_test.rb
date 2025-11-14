# frozen_string_literal: true

require 'test_helper'

class Api::ReadingCirclesTest < ActionDispatch::IntegrationTest
  test 'GET /api/reading_circles.json' do
    get api_reading_circles_path(format: :json)
    assert_response :unauthorized

    token = create_token('kimura', 'testtest')
    get api_reading_circles_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end
end
