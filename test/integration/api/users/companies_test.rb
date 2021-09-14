# frozen_string_literal: true

require 'test_helper'

class API::Users::CompaniesTest < ActionDispatch::IntegrationTest
  test 'GET /api/users/companies.json' do
    get api_users_companies_path(format: :json)
    assert_response :unauthorized

    token = create_token('kimura', 'testtest')
    get api_users_companies_path(format: :json), headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end
end
