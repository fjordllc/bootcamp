# frozen_string_literal: true

require 'test_helper'

class API::ReportsTest < ActionDispatch::IntegrationTest
  fixtures :reports

  test 'GET /api/reports.json' do
    get api_reports_path(format: :json)
    assert_response :unauthorized

    token = create_token('kimura', 'testtest')
    get api_reports_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'GET /api/reports/unchecked.json (only mentors)' do
    get api_reports_unchecked_index_path(format: :json)
    assert_response :unauthorized

    token = create_token('komagata', 'testtest')
    get api_reports_unchecked_index_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end
end
