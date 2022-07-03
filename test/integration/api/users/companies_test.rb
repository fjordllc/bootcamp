# frozen_string_literal: true

require 'test_helper'

class API::Users::CompaniesTest < ActionDispatch::IntegrationTest
  test 'should fetch all users belonging to each company' do
    token = create_token('kimura', 'testtest')
    get api_users_companies_path(format: :json, target: 'all'), headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'should fetch trainee belonging to each company' do
    token = create_token('kimura', 'testtest')
    get api_users_companies_path(format: :json, target: 'trainee'), headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'should fetch adviser belonging to each company' do
    token = create_token('kimura', 'testtest')
    get api_users_companies_path(format: :json, target: 'adviser'), headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'should fetch graduate belonging to each company' do
    token = create_token('kimura', 'testtest')
    get api_users_companies_path(format: :json, target: 'graduate'), headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'should fetch mentor belonging to each company' do
    token = create_token('kimura', 'testtest')
    get api_users_companies_path(format: :json, target: 'mentor'), headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'should not get companies' do
    get api_users_companies_path(format: :json)
    assert_response :unauthorized
  end
end
