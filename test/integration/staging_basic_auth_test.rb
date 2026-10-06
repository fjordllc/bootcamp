# frozen_string_literal: true

require 'test_helper'
require 'supports/mock_env_helper'

class StagingBasicAuthTest < ActionDispatch::IntegrationTest
  include MockEnvHelper

  test 'staging requests without authorization are challenged' do
    mock_env(staging_env) do
      get new_user_session_path
      assert_response :unauthorized
      assert_match(/\ABasic /, response.headers['WWW-Authenticate'])
    end
  end

  test 'missing or blank configured credentials are rejected' do
    %w[BASIC_AUTH_USER BASIC_AUTH_PASSWORD].each do |key|
      [nil, '', ' '].each do |credential|
        mock_env(staging_env.merge(key => credential)) do
          user = key == 'BASIC_AUTH_USER' ? credential.to_s : 'staging-user'
          password = key == 'BASIC_AUTH_PASSWORD' ? credential.to_s : 'staging-password'
          get new_user_session_path, headers: basic_auth_headers(user, password)
          assert_response :unauthorized
          assert_match(/\ABasic /, response.headers['WWW-Authenticate'])
        end
      end
    end
  end

  test 'incorrect or empty supplied credentials are rejected' do
    mock_env(staging_env) do
      [['another-user', 'staging-password'], ['x', 'staging-password'],
       ['staging-user', 'another-password'], ['staging-user', 'x'],
       ['', 'staging-password'], ['staging-user', '']].each do |user, password|
        get new_user_session_path, headers: basic_auth_headers(user, password)
        assert_response :unauthorized
      end
    end
  end

  test 'matching configured credentials allow public signin without a session' do
    mock_env(staging_env) do
      get new_user_session_path, headers: basic_auth_headers('staging-user', 'staging-password')
      assert_response :ok
    end
  end

  test 'both credentials use secure comparison when username is incorrect' do
    comparisons = []
    secure_compare = ActiveSupport::SecurityUtils.method(:secure_compare)
    compare = lambda do |supplied, configured|
      comparisons << [supplied, configured]
      secure_compare.call(supplied, configured)
    end

    mock_env(staging_env) do
      ActiveSupport::SecurityUtils.stub(:secure_compare, compare) do
        get new_user_session_path, headers: basic_auth_headers('another-user', 'staging-password')
        assert_response :unauthorized
      end
    end

    assert_equal [%w[another-user staging-user], %w[staging-password staging-password]], comparisons
  end

  test 'non staging requests bypass basic authentication' do
    mock_env('DB_NAME' => 'bootcamp_test', 'BASIC_AUTH_USER' => nil, 'BASIC_AUTH_PASSWORD' => nil) do
      get new_user_session_path
      assert_response :ok
      assert_nil response.headers['WWW-Authenticate']
    end
  end

  private

  def staging_env
    { 'DB_NAME' => 'bootcamp_staging', 'BASIC_AUTH_USER' => 'staging-user', 'BASIC_AUTH_PASSWORD' => 'staging-password' }
  end

  def basic_auth_headers(user, password)
    { 'Authorization' => ActionController::HttpAuthentication::Basic.encode_credentials(user, password) }
  end
end
