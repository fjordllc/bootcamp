# frozen_string_literal: true

require 'test_helper'

class API::PagesTest < ActionDispatch::IntegrationTest
  test 'GET /api/pages.json' do
    get api_pages_path(format: :json)
    assert_response :unauthorized

    token = create_token('kimura', 'testtest')
    get api_pages_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'GET /api/practices/315059988/pages.json' do
    practices = practices(:practice1)
    get api_pages_path(practices.id, format: :json)
    assert_response :unauthorized

    token = create_token('kimura', 'testtest')
    get api_pages_path(practices.id, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end
end
