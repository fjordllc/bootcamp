# frozen_string_literal: true

require 'test_helper'

class LoginSecurityTest < ActionDispatch::IntegrationTest
  setup do
    @rate_limit_store = ActiveSupport::Cache::MemoryStore.new
  end

  test 'account limit is shared across web and API and normalizes case and whitespace across IPs' do
    with_rate_limit_store do
      10.times do |index|
        failed_login(index.even? ? :web : :api, index.even? ? ' Synthetic-Account ' : 'synthetic-account', ip: "192.0.2.#{index + 1}")
        assert_response(index.even? ? :ok : :bad_request)
      end
      assert_equal 10, account_count('synthetic-account')

      %i[api web].each do |endpoint|
        failed_login(endpoint, 'SYNTHETIC-ACCOUNT', ip: '192.0.2.20')
        assert_throttled
      end
      assert_equal 12, account_count('synthetic-account')

      failed_login(:api, 'another-synthetic-account', ip: '192.0.2.20')
      assert_response :bad_request
      assert_equal 1, account_count('another-synthetic-account')
    end
  end

  test 'IP limit is shared across endpoints and independent of account identity' do
    with_rate_limit_store do
      100.times do |index|
        endpoint = index.even? ? :web : :api
        failed_login(endpoint, "synthetic-account-#{index}")
        assert_response(index.even? ? :ok : :bad_request)
      end
      assert_equal 100, @rate_limit_store.read('rate-limit:login:ip:192.0.2.1')

      %i[api web].each do |endpoint|
        failed_login(endpoint, 'new-synthetic-account')
        assert_throttled
      end
      assert_equal 102, @rate_limit_store.read('rate-limit:login:ip:192.0.2.1')
      assert_nil account_count('new-synthetic-account')

      failed_login(:api, 'new-synthetic-account', ip: '192.0.2.2')
      assert_response :bad_request
      assert_equal 1, account_count('new-synthetic-account')
    end
  end

  test 'account and IP limits expire after three minutes' do
    with_rate_limit_store do
      travel_to Time.current.change(usec: 0) do
        10.times { failed_login(:api, 'expiry-account') }
        90.times { |index| failed_login(:api, "expiry-account-#{index}") }
        failed_login(:web, 'expiry-account')
        assert_throttled

        travel 181.seconds
        failed_login(:web, 'expiry-account')
        assert_response :ok
        assert_equal 1, account_count('expiry-account')
        assert_equal 1, @rate_limit_store.read('rate-limit:login:ip:192.0.2.1')
      end
    end
  end

  test 'valid web and API login works below the limits' do
    with_rate_limit_store do
      sign_in(:kimura)
      assert_redirected_to root_url
      get api_users_path(format: :json)
      assert_response :ok

      post api_session_path, params: { login_name: 'kimura', password: 'testtest' }
      assert_response :ok
      assert response.parsed_body['token'].present?
      assert_equal 2, account_count('kimura')
    end
  end

  test 'throttled valid credentials issue neither session nor token' do
    with_rate_limit_store do
      10.times { failed_login(:api, 'kimura') }
      post api_session_path, params: { login_name: 'kimura', password: 'testtest' }, headers: ip_headers('192.0.2.1')
      assert_throttled
      post user_sessions_path, params: { user: { login: 'kimura', password: 'testtest' } }, headers: ip_headers('192.0.2.1')
      assert_throttled

      get api_users_path(format: :json)
      assert_response :unauthorized
    end
  end

  test 'throttling does not log out an existing session and does not affect new or destroy' do
    sign_in(:kimura)
    with_rate_limit_store do
      10.times { failed_login(:api, 'synthetic-account') }
      # Failed API login clears the prior identity; establish a fresh session below its own limit.
      sign_in(:kimura)
      post api_session_path, params: { login_name: 'synthetic-account', password: 'wrong-password' }, headers: ip_headers('192.0.2.1')
      assert_throttled
      get api_users_path(format: :json)
      assert_response :ok
      get login_path
      assert_response :ok
      sign_out
      assert_redirected_to root_url
      get api_users_path(format: :json)
      assert_response :unauthorized
    end
  end

  test 'missing and malformed account identities have a bounded safe throttle key' do
    with_rate_limit_store do
      10.times { failed_login(:api, nil) }
      assert_equal 10, account_count('')
      post api_session_path, params: { login_name: { unexpected: 'synthetic' }, password: 'wrong-password' }
      assert_throttled
      post user_sessions_path, params: { user: { login: ['synthetic'], password: 'wrong-password' } }
      assert_throttled
      post user_sessions_path, params: { user: 'malformed' }
      assert_throttled
      post user_sessions_path, params: { password: 'wrong-password' }
      assert_throttled
    end
  end

  test 'account throttle notifications contain only a digest identity' do
    with_rate_limit_store do
      10.times { failed_login(:api, 'synthetic@example.invalid') }
      events = []
      subscriber = ->(event) { events << event.payload }
      ActiveSupport::Notifications.subscribed(subscriber, 'rate_limit.action_controller') do
        failed_login(:api, 'synthetic@example.invalid')
        assert_throttled
      end
      assert_equal 1, events.size
      assert_equal Digest::SHA256.hexdigest('synthetic@example.invalid'), events.first[:by]
      assert_equal "rate-limit:login:account:#{events.first[:by]}", events.first[:cache_key]
    end
  end

  private

  def with_rate_limit_store
    # Rails captures the store when defining the callback. Delegate only increment
    # on those captured stores, leaving the suite's NullStore configuration intact.
    stores = [UserSessionsController.cache_store, API::SessionController.cache_store].uniq
    increment = ->(*args, **options) { @rate_limit_store.increment(*args, **options) }
    with_stores = lambda do |remaining|
      if remaining.empty?
        yield
      else
        remaining.first.stub(:increment, increment) { with_stores.call(remaining.drop(1)) }
      end
    end
    with_stores.call(stores)
  end

  def failed_login(endpoint, identifier, ip: '192.0.2.1')
    if endpoint == :web
      post user_sessions_path, params: { user: { login: identifier, password: 'wrong-password' } }, headers: ip_headers(ip)
    else
      post api_session_path, params: { login_name: identifier, password: 'wrong-password' }, headers: ip_headers(ip)
    end
  end

  def ip_headers(ip)
    { 'REMOTE_ADDR' => ip }
  end

  def account_count(identifier)
    @rate_limit_store.read("rate-limit:login:account:#{Digest::SHA256.hexdigest(identifier)}")
  end

  def assert_throttled
    assert_response :too_many_requests
    assert_empty response.body
    assert_nil response.headers['Location']
  end
end
