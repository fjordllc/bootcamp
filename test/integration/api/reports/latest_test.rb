# frozen_string_literal: true

require 'test_helper'

class API::Reports::LatestTest < ActionDispatch::IntegrationTest
  fixtures :reports

  test 'returns unauthorized when not logged in' do
    get api_reports_latest_path(format: :json)
    assert_response :unauthorized
  end

  test 'returns not found when no reports exist' do
    token = create_token('sotugyou-with-job', 'testtest')
    get api_reports_latest_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :not_found
    assert_equal '最新の日報が見つかりません。', response.parsed_body['message']
  end

  test 'returns own report even when other user has a more recent report' do
    token = create_token('machida', 'testtest')
    get api_reports_latest_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
    assert_equal reports(:report4).id, response.parsed_body['id']
  end
end
