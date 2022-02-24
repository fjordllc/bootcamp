# frozen_string_literal: true

require 'test_helper'

class API::PracticesPagesTest < ActionDispatch::IntegrationTest
  test 'GET /api/practices/315059988/pages.json' do
    @practices = practices(:practice1)
    get api_practice_pages_path(@practices.id, format: :json)
    assert_response :unauthorized

    token = create_token('kimura', 'testtest')
    get api_practice_pages_path(@practices.id, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end
end
