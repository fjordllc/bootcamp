# frozen_string_literal: true

require 'test_helper'
require 'open3'
require 'rbconfig'

class RollbarInvalidAuthenticityTokenTest < ActiveSupport::TestCase
  REQUEST_SCRIPT = <<~'RUBY'
    require 'rails'
    require 'action_controller'
    require 'action_dispatch'
    require 'rollbar'
    require 'rollbar/middleware/rails/rollbar'
    require 'rollbar/middleware/rails/show_exceptions'
    require 'json'
    require 'logger'
    require 'stringio'

    load File.expand_path('config/initializers/rollbar.rb')
    reports = []
    Rollbar.configure do |config|
      config.access_token = 'test-token'
      config.logger = Logger.new(File::NULL)
      config.use_async = true
      config.async_handler = ->(payload) { reports << payload }
    end

    class RollbarCsrfTestController < ActionController::Base
      protect_from_forgery with: :exception

      def index
        raise 'unexpected failure' if request.path_info == '/unexpected'

        render plain: 'processed'
      end
    end

    ActionDispatch::DebugExceptions.include(Rollbar::Middleware::Rails::ShowExceptions)
    app = ActionDispatch::ShowExceptions.new(
      ActionDispatch::DebugExceptions.new(
        Rollbar::Middleware::Rails::RollbarMiddleware.new(RollbarCsrfTestController.action(:index))
      ),
      ActionDispatch::PublicExceptions.new(File.expand_path('public'))
    )
    log = StringIO.new
    env = Rack::MockRequest.env_for(
      ARGV.fetch(1),
      method: ARGV.fetch(0),
      params: ARGV.fetch(3).empty? ? {} : { authenticity_token: ARGV.fetch(3) },
      'HTTP_ACCEPT' => 'text/html',
      'rack.session' => { _csrf_token: ARGV.fetch(2) },
      'action_dispatch.logger' => ActiveSupport::Logger.new(log),
      'action_dispatch.log_rescued_responses' => true,
      'action_dispatch.show_exceptions' => :all,
      'action_dispatch.show_detailed_exceptions' => false
    )
    status, _headers, body = app.call(env)
    puts JSON.generate(
      status: status,
      body: body.each.to_a.join,
      exception: env['action_dispatch.exception']&.class&.name,
      enabled: Rollbar.configuration.enabled,
      log: log.string,
      reports: reports
    )
  RUBY

  test 'request without CSRF token is rejected and logged without a Rollbar report' do
    result = request('POST', '/')

    assert_rejected_without_report result
  end

  test 'request with wrong CSRF token is rejected and logged without a Rollbar report' do
    stale_token = SecureRandom.urlsafe_base64(32)
    result = request('POST', '/', authenticity_token: stale_token)

    assert_rejected_without_report result
    assert_not_includes result.fetch('body'), stale_token
  end

  test 'request with the CSRF token of its session is processed normally' do
    session_token = SecureRandom.urlsafe_base64(32)
    result = request('POST', '/', session_token:, authenticity_token: session_token)

    assert_equal 200, result.fetch('status')
    assert_equal 'processed', result.fetch('body')
    assert_nil result.fetch('exception')
    assert_empty result.fetch('reports')
  end

  test 'unexpected errors are still reported' do
    result = request('GET', '/unexpected')

    assert_equal 500, result.fetch('status')
    assert_equal 'RuntimeError', result.fetch('exception')
    assert_includes result.fetch('log'), 'RuntimeError'
    assert_not_includes result.fetch('body'), 'unexpected failure'
    reports = result.fetch('reports')

    assert_equal 1, reports.size
    assert_equal 'RuntimeError', reports.first.fetch('data').fetch('body').fetch('trace').fetch('exception').fetch('class')
  end

  private

  def assert_rejected_without_report(result)
    assert_equal 422, result.fetch('status')
    assert_equal 'ActionController::InvalidAuthenticityToken', result.fetch('exception')
    assert_empty result.fetch('reports')
    assert_includes result.fetch('log'), result.fetch('exception')
    assert_not_includes result.fetch('body'), result.fetch('exception')
    assert_not_includes result.fetch('body'), 'processed'
  end

  def request(method, path, session_token: SecureRandom.urlsafe_base64(32), authenticity_token: '')
    stdout, stderr, status = Open3.capture3(
      { 'RAILS_ENV' => 'production', 'ROLLBAR_ACCESS_TOKEN' => nil },
      RbConfig.ruby, '-e', REQUEST_SCRIPT, method, path, session_token, authenticity_token,
      chdir: Rails.root.to_s
    )

    assert_predicate status, :success?, stderr
    result = JSON.parse(stdout)

    assert result.fetch('enabled'), 'Rollbar must be enabled to test exception reporting'
    result
  end
end
