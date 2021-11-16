# frozen_string_literal: true

require 'test_helper'

class API::FeaturedEntriesTest < ActionDispatch::IntegrationTest
  test 'GET /api/featured_entries.json' do
    get api_featured_entries_path(format: :json)
    assert_response :unauthorized

    token = create_token('komagata', 'testtest')
    get api_featured_entries_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'POST /api/featured_entries.json' do
    report = reports(:report1)
    post api_featured_entries_path(format: :json),
         params: {
           featureable_id: report.id,
           featureable_type: 'Report'
        }
    assert_response :unauthorized

    token = create_token('machida', 'testtest')
    post api_featured_entries_path(format: :json),
         params: {
           featureable_id: report.id,
           featureable_type: 'Report'
         },
         headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :created
  end

  test 'DELETE /api/featured_entries/1234.json' do
    featured_entry = featured_entries(:featured_entry1)
    delete api_featured_entry_path(featured_entry.id, format: :json)
    assert_response :unauthorized

    token = create_token('komagata', 'testtest')
    delete api_featured_entry_path(featured_entry.id, format: :json),
           headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :no_content
  end
end
