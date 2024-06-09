# frozen_string_literal: true

require 'test_helper'

class API::Reports::UncheckedTest < ActionDispatch::IntegrationTest
  fixtures :reports

  test 'GET /api/reports/unchecked/counts.txt' do
    get counts_api_reports_unchecked_index_path(format: :text)
    assert_response :unauthorized

    token = create_token('komagata', 'testtest')
    get counts_api_reports_unchecked_index_path(format: :text),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
    assert_match '66件', response.body
  end
end
