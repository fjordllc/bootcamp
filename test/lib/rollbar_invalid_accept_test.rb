# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require 'open3'
require 'rbconfig'

class RollbarInvalidAcceptTest < Minitest::Test
  # Isolate the production Rollbar configuration from the Rails test process.
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

    class RollbarAcceptTestController < ActionController::Base
      def index
        case request.path_info
        when '/unexpected'
          raise 'unexpected failure'
        when '/mime-error'
          raise Mime::Type::InvalidMimeType, 'unexpected MIME error'
        when '/content-type'
          render plain: request.content_mime_type.to_s
        else
          render plain: request.format.to_s
        end
      end
    end

    # Match the middleware order and DebugExceptions hook from Rollbar's railtie.
    ActionDispatch::DebugExceptions.include(Rollbar::Middleware::Rails::ShowExceptions)
    app = ActionDispatch::ShowExceptions.new(
      ActionDispatch::DebugExceptions.new(
        Rollbar::Middleware::Rails::RollbarMiddleware.new(RollbarAcceptTestController.action(:index))
      ),
      ActionDispatch::PublicExceptions.new(File.expand_path('public'))
    )
    log = StringIO.new
    env = Rack::MockRequest.env_for(
      ARGV.fetch(0),
      'HTTP_ACCEPT' => ARGV.fetch(1),
      'action_dispatch.logger' => ActiveSupport::Logger.new(log),
      'action_dispatch.log_rescued_responses' => true,
      'action_dispatch.show_exceptions' => :all,
      'action_dispatch.show_detailed_exceptions' => false
    )
    env['CONTENT_TYPE'] = ARGV.fetch(2) unless ARGV.fetch(2).empty?
    status, _headers, body = app.call(env)
    puts JSON.generate(
      status: status,
      body: body.each.to_a.join,
      exception: env['action_dispatch.exception']&.class&.name,
      cause: env['action_dispatch.exception']&.cause&.class&.name,
      enabled: Rollbar.configuration.enabled,
      log: log.string,
      reports: reports
    )
  RUBY

  def test_invalid_accept_is_not_reported_and_remains_not_acceptable
    invalid_type = '../../../../../../../../../../etc/services{{'
    result = request('/', invalid_type)

    assert_equal 406, result.fetch('status')
    assert_equal 'ActionDispatch::Http::MimeNegotiation::InvalidType', result.fetch('exception')
    assert_equal 'Mime::Type::InvalidMimeType', result.fetch('cause')
    assert_empty result.fetch('reports')
    assert_includes result.fetch('log'), result.fetch('exception')
    assert_generic_error_response result, invalid_type
  end

  def test_invalid_content_type_is_logged_without_a_rollbar_report
    invalid_type = 'invalid-content-type{{'
    result = request('/content-type', 'text/html', content_type: invalid_type)

    assert_equal 406, result.fetch('status')
    assert_equal 'ActionDispatch::Http::MimeNegotiation::InvalidType', result.fetch('exception')
    assert_equal 'Mime::Type::InvalidMimeType', result.fetch('cause')
    assert_empty result.fetch('reports')
    assert_includes result.fetch('log'), result.fetch('exception')
    assert_generic_error_response result, invalid_type
  end

  def test_valid_accept_is_processed_normally
    %w[text/html application/json].each do |accept|
      result = request('/', accept)

      assert_equal 200, result.fetch('status')
      assert_equal accept, result.fetch('body')
      assert_empty result.fetch('reports')
    end
  end

  def test_unexpected_errors_are_still_reported
    { '/unexpected' => 'RuntimeError', '/mime-error' => 'Mime::Type::InvalidMimeType' }.each do |path, exception|
      result = request(path, 'text/html')

      assert_equal 500, result.fetch('status')
      assert_equal exception, result.fetch('exception')
      assert_includes result.fetch('log'), exception
      assert_generic_error_response result, 'unexpected failure', 'unexpected MIME error'
      reports = result.fetch('reports')

      assert_equal 1, reports.size
      assert_equal exception, reports.first.fetch('data').fetch('body').fetch('trace').fetch('exception').fetch('class')
    end
  end

  private

  def assert_generic_error_response(result, *details)
    body = result.fetch('body')

    [*details, result.fetch('exception'), 'REQUEST_SCRIPT', '-e:', 'Traceback'].each do |detail|
      # Standalone Minitest does not provide Rails' assert_not_includes helper.
      refute_includes body, detail # rubocop:disable Rails/RefuteMethods
    end
  end

  def request(path, accept, content_type: '')
    stdout, stderr, status = Open3.capture3(
      { 'RAILS_ENV' => 'production', 'ROLLBAR_ACCESS_TOKEN' => nil },
      RbConfig.ruby, '-e', REQUEST_SCRIPT, path, accept, content_type,
      chdir: File.expand_path('../..', __dir__)
    )

    assert_predicate status, :success?, stderr
    result = JSON.parse(stdout)

    assert result.fetch('enabled'), 'Rollbar must be enabled to test exception reporting'
    result
  end
end
