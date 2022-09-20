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

  test 'GET /api/pages.json?tags=beginner' do
    tag = acts_as_taggable_on_tags('beginner')
    get api_pages_path(tag, format: :json)
    assert_response :unauthorized

    token = create_token('kimura', 'testtest')
    get api_pages_path(tag, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'GET /api/pages.json?practice_id=315059988' do
    practices = practices(:practice1)
    get api_pages_path(practices.id, format: :json)
    assert_response :unauthorized

    token = create_token('kimura', 'testtest')
    get api_pages_path(practices.id, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'GET /api/pages?page=9999' do
    token = create_token('kimura', 'testtest')
    get api_pages_path,
        headers: { 'Authorization' => "Bearer #{token}" },
        params: { page: '9999' }
    assert_response :missing
  end
end
