# frozen_string_literal: true

require 'test_helper'

class API::Admin::CompaniesTest < ActionDispatch::IntegrationTest
  fixtures :users

  test 'GET /api/admin/companies.json' do
    get api_admin_companies_path(format: :json)
    assert_response :unauthorized

    token = create_token('komagata', 'testtest')
    get api_users_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'DELETE /api/admin/companies/1234.json' do
    token = create_token('komagata', 'testtest')
    get api_admin_companies_path

    delete api_admin_company_path(companies(:company2).id, format: :json),
           headers: { 'Authorization' => "Bearer #{token}" }

    assert_response :success
  end
end
