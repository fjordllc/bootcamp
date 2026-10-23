# frozen_string_literal: true

require 'test_helper'
require 'supports/mock_env_helper'

class PerformanceControllerTest < ActionDispatch::IntegrationTest
  test 'admin dashboard is protected from anonymous student and mentor access' do
    get '/admin/performance'
    assert_redirected_to root_path
    %w[kimura mentormentaro].each do |name|
      get '/admin/performance', params: { _login_name: name }
      assert_redirected_to root_path
    end
  end

  test 'admin sees honest unconfigured state and all ten pages' do
    get '/admin/performance', params: { _login_name: 'komagata' }
    assert_response :success
    assert_select 'h1', 'パフォーマンス'
    assert_match '設定が必要です', response.body
    assert_select '[data-performance-page]', count: 10
    assert_select '[data-summary-rating=unknown] .a-badge.is-muted', text: '判定待ち'
    assert_select '[data-rating=good]', count: 0
    assert_match(/対象:.*直近24時間/m, response.body)
    assert_match(%r{\d{4}/\d{2}/\d{2} \d{2}:00}, response.body)
  end

  test 'collector rejects malformed injected secrets before request logging' do
    logs = StringIO.new
    Rails.stub(:logger, ActiveSupport::Logger.new(logs)) do
      %w[/api/performance_reports /api/performance_reports/ /api/performance_reports.json].each do |path|
        post path, params: '{"sentinel":"private@example.invalid"', headers: { 'CONTENT_TYPE' => 'application/json' }
        assert_response :bad_request
      end
    end
    assert_response :bad_request
    assert_not_includes logs.string, 'private@example.invalid'
  end
end

class PerformanceCollectorSecurityTest < ActionDispatch::IntegrationTest
  include MockEnvHelper

  setup do
    @previous_forgery = ApplicationController.allow_forgery_protection
    ApplicationController.allow_forgery_protection = true
    https!
    @output = StringIO.new
    @writer = Performance::LogWriter.new(output: @output)
    cache = ActiveSupport::Cache::MemoryStore.new
    state = Object.new
    state.define_singleton_method(:read) { |key| cache.read(key) }
    state.define_singleton_method(:write) { |key, value, **options| cache.write(key, value, **options) }
    state.define_singleton_method(:synchronize) { |_lock, &block| block.call(self) }
    @gate = Performance::ReportGate.new(state:)
  end

  teardown do
    ApplicationController.allow_forgery_protection = @previous_forgery
  end

  test 'real CSRF authenticated ticket is accepted once and no missing INP zero is emitted' do
    configured do
      visit_sample
      @output.truncate(0)
      @output.rewind
      2.times do
        post_packet
        assert_response :no_content
      end
      records = @output.string.lines.map { |line| JSON.parse(line) }
      assert_equal 3, records.length
      inp = records.find { |record| record['metric'] == 'INP' }
      assert_equal 'unobserved', inp['state']
      assert_not inp.key?('value')
      assert_equal 'no-store', response.headers['Cache-Control']
    end
  end

  test 'staging Basic authentication can coexist with cookie CSRF reports' do
    basic = ActionController::HttpAuthentication::Basic.encode_credentials('preview', 'synthetic-only')
    configured('DB_NAME' => 'bootcamp_staging', 'BASIC_AUTH_USER' => 'preview', 'BASIC_AUTH_PASSWORD' => 'synthetic-only') do
      visit_sample(request_headers: { 'Authorization' => basic })
      @output.truncate(0)
      @output.rewind

      post_packet(extra: { 'Authorization' => basic })
      assert_response :no_content
      records = @output.string.lines.map { |line| JSON.parse(line) }
      assert_equal 3, records.length

      invalid_basic = ActionController::HttpAuthentication::Basic.encode_credentials('preview', 'wrong-password')
      post_packet(extra: { 'Authorization' => invalid_basic })
      assert_response :unauthorized
      assert_equal(records, @output.string.lines.map { |line| JSON.parse(line) })
    end
  end

  test 'missing and wrong CSRF and origin cannot consume ticket or emit values' do
    configured do
      visit_sample
      @output.truncate(0)
      @output.rewind
      post_packet(csrf: nil)
      assert_response :unprocessable_entity
      post_packet(csrf: 'wrong')
      assert_response :unprocessable_entity
      post_packet(origin: 'https://hostile.invalid')
      assert_response :forbidden
      post_packet(site: 'cross-site')
      assert_response :forbidden
      assert_empty @output.string
      post_packet
      assert_response :no_content
    end
  end

  test 'collector has no bearer or test-login bypass and uses empty unauthorized responses' do
    configured do
      @packet = packet('forged')
      @csrf = 'forged'
      post_packet(extra: { 'Authorization' => 'Bearer fake' })
      assert_response :unauthorized
      assert_empty response.body
      assert_empty @output.string
    end
  end

  test 'schema rejects unknown keys including PII keys before Rails logs' do
    configured do
      visit_sample
      logs = StringIO.new
      @packet['private@example.invalid'] = 'sentinel-secret'
      Rails.stub(:logger, ActiveSupport::Logger.new(logs)) { post_packet }
      assert_response :bad_request
      assert_not_includes logs.string, 'private@example.invalid'
      assert_not_includes logs.string, 'sentinel-secret'
    end
  end

  private

  def configured(extra_env = {}, &block)
    mock_env({ 'PERFORMANCE_COLLECTION_ENABLED' => 'true', 'APP_HOST_NAME' => 'www.example.com' }.merge(extra_env)) do
      Performance::ReportGate.stub(:new, @gate) do
        Performance::LogWriter.stub(:new, @writer, &block)
      end
    end
  end

  def visit_sample(request_headers: {})
    Random.stub(:rand, 0) { get reports_path, params: { _login_name: 'kimura' }, headers: request_headers }
    assert_response :success
    html = Nokogiri::HTML(response.body)
    @csrf = html.at_css('meta[name="csrf-token"]')['content']
    @packet = packet(html.at_css('meta[name="performance-token"]')['content'])
  end

  def packet(token)
    { 'performance_report' => { 'token' => token, 'page' => 'reports_index', 'device' => 'mobile', 'metrics' => {
      'LCP' => { 'state' => 'observed', 'value' => 2400 }, 'INP' => { 'state' => 'unobserved' }, 'CLS' => { 'state' => 'observed', 'value' => 0.04 }
    } } }
  end

  def post_packet(csrf: @csrf, origin: 'https://www.example.com', site: 'same-origin', extra: {})
    headers = { 'CONTENT_TYPE' => 'application/json', 'Origin' => origin, 'Sec-Fetch-Site' => site }.merge(extra)
    headers['X-CSRF-Token'] = csrf if csrf
    post '/api/performance_reports', params: JSON.generate(@packet), headers:
  end
end
