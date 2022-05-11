# frozen_string_literal: true

require 'test_helper'

class API::ReportsTest < ActionDispatch::IntegrationTest
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

  test 'GET /api/reports.json?user_id=984742968' do
    user = users(:with_hyphen)
    get api_reports_path(user_id: user.id, format: :json)
    assert_response :unauthorized

    token = create_token('kimura', 'testtest')
    get api_reports_path(user_id: user.id, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'GET /api/reports.json?company_id=362477616' do
    company = companies(:company4)
    get api_reports_path(company_id: company.id, format: :json)
    assert_response :unauthorized

    token = create_token('kimura', 'testtest')
    get api_reports_path(company_id: company.id, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end
end
