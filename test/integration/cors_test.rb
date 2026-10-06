# frozen_string_literal: true

require 'test_helper'

class CorsTest < ActionDispatch::IntegrationTest
  EXTENSION_ORIGIN = 'chrome-extension://ddobgcfepfdpccmgnpfgjcomccpkcdjj'
  UNKNOWN_ORIGIN = 'https://untrusted.example'

  test 'ordinary web responses do not grant CORS access to unknown origins' do
    get root_path, headers: { 'Origin' => UNKNOWN_ORIGIN }

    assert_response :success
    assert_no_cors_grant
  end

  test 'public API responses do not grant CORS access to unknown origins' do
    get api_tags_path(format: :json), params: { taggable_type: 'Page' }, headers: { 'Origin' => UNKNOWN_ORIGIN }

    assert_response :success
    assert_no_cors_grant
  end

  test 'requests without an origin still serve web and public API responses' do
    get root_path

    assert_response :success
    assert_no_cors_grant

    get api_tags_path(format: :json), params: { taggable_type: 'Page' }

    assert_response :success
    assert_no_cors_grant
  end

  test 'extension origin can read public API responses with credentials' do
    get api_tags_path(format: :json), params: { taggable_type: 'Page' }, headers: { 'Origin' => EXTENSION_ORIGIN }

    assert_response :success
    assert_equal EXTENSION_ORIGIN, response.headers['Access-Control-Allow-Origin']
    assert_equal 'true', response.headers['Access-Control-Allow-Credentials']
    assert_includes response.headers['Access-Control-Allow-Methods'].split(', '), 'GET'
    assert_not_includes response.headers['Access-Control-Allow-Methods'], '*'
  end

  test 'extension API preflight allows the requested method and headers with credentials' do
    options api_tags_path(format: :json), headers: {
      'Origin' => EXTENSION_ORIGIN,
      'Access-Control-Request-Method' => 'PATCH',
      'Access-Control-Request-Headers' => 'authorization, content-type'
    }

    assert_response :success
    assert_equal EXTENSION_ORIGIN, response.headers['Access-Control-Allow-Origin']
    assert_equal 'true', response.headers['Access-Control-Allow-Credentials']
    assert_includes response.headers['Access-Control-Allow-Methods'].split(', '), 'PATCH'
    assert_not_includes response.headers['Access-Control-Allow-Methods'], '*'
    assert_equal 'authorization, content-type', response.headers['Access-Control-Allow-Headers']
  end

  test 'unknown origin API preflight receives no CORS grant' do
    options api_tags_path(format: :json), headers: {
      'Origin' => UNKNOWN_ORIGIN,
      'Access-Control-Request-Method' => 'PATCH',
      'Access-Control-Request-Headers' => 'authorization, content-type'
    }

    assert_response :success
    assert_no_cors_grant
    assert_nil response.headers['Access-Control-Allow-Headers']
  end

  test 'extension origin receives no CORS grant outside API routes' do
    get root_path, headers: { 'Origin' => EXTENSION_ORIGIN }

    assert_response :success
    assert_no_cors_grant
  end

  private

  def assert_no_cors_grant
    assert_nil response.headers['Access-Control-Allow-Origin']
    assert_nil response.headers['Access-Control-Allow-Methods']
    assert_nil response.headers['Access-Control-Allow-Credentials']
  end
end
