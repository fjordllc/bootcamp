# frozen_string_literal: true

require 'test_helper'

class Performance::ReaderTest < ActiveSupport::TestCase
  setup do
    @window = { start: Time.utc(2026, 10, 19, 12), end: Time.utc(2026, 10, 20, 12) }
    @config = Performance::Configuration.new('PERFORMANCE_DASHBOARD_ENABLED' => 'true', 'PERFORMANCE_PROJECT_ID' => 'school-project',
                                             'PERFORMANCE_CLOUD_RUN_SERVICE' => 'bootcamp', 'PERFORMANCE_CLOUD_RUN_REGION' => 'asia-northeast1',
                                             'PERFORMANCE_COLLECTION_STARTED_AT' => '2026-10-01T00:00:00Z')
  end

  test 'uses fixed hourly summed query and merges sparse hourly populations' do
    calls = []
    transport = Object.new
    series = distribution_series
    transport.define_singleton_method(:get) do |path, params|
      calls << [path, params]
      if path.include?('metricDescriptors')
        { 'metricKind' => 'DELTA', 'valueType' => 'DISTRIBUTION', 'unit' => 'ms',
          'labels' => [{ 'key' => 'page' }] }
      else
        { 'timeSeries' => [series] }
      end
    end
    result = Performance::MonitoringReader.new(config: @config, transport:).read(window: @window)
    server = result.fetch('server')
    assert_equal :ready, server[:state]
    assert_equal 100, server[:groups].fetch(['reports_index']).count
    assert_equal [0, 50], server[:groups].fetch(['reports_index']).quantile(0.95)
    params = calls.first.last
    assert_includes params, ['aggregation.perSeriesAligner', 'ALIGN_SUM']
    assert_includes params, ['aggregation.crossSeriesReducer', 'REDUCE_SUM']
    assert_includes params, ['aggregation.alignmentPeriod', '3600s']
    assert_includes params, %w[pageSize 10000]
    assert_includes params, ['interval.endTime', '2026-10-20T12:00:00Z']
    assert_includes params, ['aggregation.groupByFields', 'metric.labels.page']
    assert_includes params.assoc('filter').last, 'resource.labels.service_name = "bootcamp"'
  end

  test 'overlapping or out of window points are invalid and never rated' do
    series = distribution_series
    series['points'] << series['points'].first.deep_dup
    result = Performance::MetricPopulation.new('server', @window).parse([series])
    assert_equal :invalid_schema, result[:state]
    series['points'] = [series['points'].first.merge('interval' => { 'startTime' => '2026-10-18T12:00:00Z', 'endTime' => '2026-10-18T13:00:00Z' })]
    assert_equal :invalid_schema, Performance::MetricPopulation.new('server', @window).parse([series])[:state]
  end

  test 'unknown labels invalid schema and errors on successful HTTP are partial' do
    series = distribution_series
    series['metric']['labels']['page'] = 'private@example.invalid'
    assert_equal :invalid_schema, Performance::MetricPopulation.new('server', @window).parse([series])[:state]
    transport = Object.new
    transport.define_singleton_method(:get) { |_path, _params| { 'executionErrors' => [{ 'message' => 'secret' }] } }
    result = Performance::MonitoringReader.new(config: @config, transport:).read(window: @window)
    assert_equal :partial, result['server'][:state]
    assert_not_includes result.inspect, 'secret'
  end

  private

  def distribution_series
    bounds = Performance::MetricSpecs::SPECS.fetch('server').fetch(:bounds)
    { 'metricKind' => 'DELTA', 'valueType' => 'DISTRIBUTION', 'unit' => 'ms', 'metric' => { 'labels' => { 'page' => 'reports_index' } },
      'points' => [[12, 99, 1], [15, 1, 15]].map do |hour, count, bucket|
        counts = Array.new(bounds.length + 1, '0')
        counts[bucket] = count.to_s
        { 'interval' => { 'startTime' => Time.utc(2026, 10, 19, hour).iso8601, 'endTime' => Time.utc(2026, 10, 19, hour + 1).iso8601 },
          'value' => { 'distributionValue' => { 'count' => count.to_s, 'bucketCounts' => counts,
                                                'bucketOptions' => { 'explicitBuckets' => { 'bounds' => bounds } } } } }
      end }
  end
end

class Performance::TransportTest < ActiveSupport::TestCase
  test 'outer authentication deadline interrupts blocked ADC work without calling Monitoring' do
    transport = Performance::MonitoringTransport.new(auth: -> { Queue.new.pop }, auth_budget: 0.02)
    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    error = assert_raises(Performance::MonitoringTransport::Error) { transport.get('/v3/projects/school-project/timeSeries', []) }
    assert_equal :credential_error, error.state
    assert_operator Process.clock_gettime(Process::CLOCK_MONOTONIC) - started, :<, 0.5
  end

  test 'HTTP work respects total deadline and disables automatic retries' do
    connection = Net::HTTP.new('monitoring.googleapis.com', 443)
    connection.define_singleton_method(:request) { |*_args| Queue.new.pop }
    http = Object.new
    http.define_singleton_method(:new) do |host, port|
      raise ArgumentError unless host == 'monitoring.googleapis.com' && port == 443

      connection
    end
    transport = Performance::MonitoringTransport.new(auth: -> { 'ephemeral' }, http:, budget: 0.03)
    error = assert_raises(Performance::MonitoringTransport::Error) { transport.get('/v3/projects/school-project/timeSeries', []) }
    assert_equal :timeout, error.state
    assert_equal 0, connection.max_retries
    assert_equal OpenSSL::SSL::VERIFY_PEER, connection.verify_mode
    assert connection.use_ssl?
  end

  test 'HTTP failures and unexpected bodies never retain Google error details' do
    url = 'https://monitoring.googleapis.com/v3/projects/school-project/timeSeries'
    stub_request(:get, url).with(headers: { 'Authorization' => 'Bearer ephemeral' }).to_return(status: 403, body: 'private@example.invalid')
    transport = Performance::MonitoringTransport.new(auth: -> { 'ephemeral' })
    error = assert_raises(Performance::MonitoringTransport::Error) { transport.get('/v3/projects/school-project/timeSeries', []) }
    assert_equal :permission_error, error.state
    assert_not_includes error.message, 'private@example.invalid'
    stub_request(:get, url).to_return(status: 302, headers: { 'Location' => 'https://hostile.invalid' })
    assert_raises(Performance::MonitoringTransport::Error) { transport.get('/v3/projects/school-project/timeSeries', []) }
    assert_not_requested :get, 'https://hostile.invalid'
  end

  test 'response byte limit aborts a large response and request count cannot exceed fifteen' do
    url = 'https://monitoring.googleapis.com/v3/projects/school-project/timeSeries'
    stub_request(:get, url).to_return(status: 200, body: 'x' * (4.megabytes + 1))
    transport = Performance::MonitoringTransport.new(auth: -> { 'ephemeral' })
    error = assert_raises(Performance::MonitoringTransport::Error) { transport.get('/v3/projects/school-project/timeSeries', []) }
    assert_equal :partial, error.state
    stub_request(:get, url).to_return(status: 200, body: '{}')
    transport = Performance::MonitoringTransport.new(auth: -> { 'ephemeral' })
    15.times { assert_empty(transport.get('/v3/projects/school-project/timeSeries', [])) }
    error = assert_raises(Performance::MonitoringTransport::Error) { transport.get('/v3/projects/school-project/timeSeries', []) }
    assert_equal :partial, error.state
  end
end

class Performance::ReaderBoundsTest < ActiveSupport::TestCase
  setup do
    @window = { start: Time.utc(2026, 10, 19, 12), end: Time.utc(2026, 10, 20, 12) }
    @config = Performance::Configuration.new('PERFORMANCE_PROJECT_ID' => 'school-project', 'PERFORMANCE_CLOUD_RUN_SERVICE' => 'school',
                                             'PERFORMANCE_CLOUD_RUN_REGION' => 'asia-northeast1')
  end

  test 'a third page token is partial and cannot be silently truncated into good data' do
    calls = []
    transport = Object.new
    transport.define_singleton_method(:get) do |_path, params|
      calls << params
      { 'timeSeries' => [], 'nextPageToken' => 'another-page' }
    end
    results = Performance::MonitoringReader.new(config: @config, transport:).read(window: @window)
    assert(results.values.all? { |result| result[:state] == :partial && result[:groups].empty? })
    assert_equal 10, calls.length
    assert_includes calls[1], %w[pageToken another-page]
  end

  test 'an empty response distinguishes missing descriptor from an existing metric without observations' do
    calls = []
    transport = Object.new
    transport.define_singleton_method(:get) do |path, _params|
      calls << path
      raise Performance::MonitoringTransport::Error, :missing_metric if path.include?('metricDescriptors')

      {}
    end
    results = Performance::MonitoringReader.new(config: @config, transport:).read(window: @window)
    assert_equal :missing_metric, results['server'][:state]
    assert_equal 10, calls.length
  end

  test 'valid descriptor schema is cached and no data stays empty instead of zero latency' do
    cache = ActiveSupport::Cache::MemoryStore.new
    transport = Object.new
    calls = []
    transport.define_singleton_method(:get) do |path, _params|
      calls << path
      next {} unless path.include?('metricDescriptors')

      metric, spec = Performance::MetricSpecs::SPECS.find { |_key, entry| path.end_with?(entry[:name]) }
      { 'metricKind' => 'DELTA', 'valueType' => metric == 'coverage' ? 'INT64' : 'DISTRIBUTION', 'unit' => spec[:unit],
        'labels' => Performance::MetricSpecs.labels(metric).map { |key| { 'key' => key, 'valueType' => 'STRING' } } }
    end
    reader = Performance::MonitoringReader.new(config: @config, transport:, state: cache)
    2.times do
      results = reader.read(window: @window)
      assert_equal({ state: :ready, groups: {} }, results['server'])
    end
    assert_equal(5, calls.count { |path| path.include?('metricDescriptors') })
    assert_equal 15, calls.length
  end

  test 'too many returned hourly points invalidates the entire metric and IAM failure stops subsequent calls' do
    calls = 0
    transport = Object.new
    transport.define_singleton_method(:get) do |_path, _params|
      calls += 1
      { 'timeSeries' => [{ 'points' => Array.new(10_001, {}) }] }
    end
    results = Performance::MonitoringReader.new(config: @config, transport:).read(window: @window)
    assert_equal :partial, results['server'][:state]
    assert_equal 5, calls
    transport.define_singleton_method(:get) do |_path, _params|
      calls += 1
      raise Performance::MonitoringTransport::Error, :permission_error
    end
    results = Performance::MonitoringReader.new(config: @config, transport:).read(window: @window)
    assert_equal 6, calls
    assert_equal :permission_error, results['CLS'][:state]
  end
end

class Performance::ADCTest < ActiveSupport::TestCase
  test 'standard ADC uses only monitoring read scope and is not shared with storage credentials' do
    credentials = Object.new
    credentials.define_singleton_method(:fetch_access_token!) { { 'access_token' => 'ephemeral' } }
    stub_request(:get, 'https://monitoring.googleapis.com/v3/projects/school-project/timeSeries').to_return(body: '{}')
    discovery = lambda do |scope|
      assert_equal ['https://www.googleapis.com/auth/monitoring.read'], scope
      credentials
    end
    Google::Auth.stub(:get_application_default, discovery) do
      assert_empty Performance::MonitoringTransport.new.get('/v3/projects/school-project/timeSeries', [])
    end
  end

  test 'refresh-wide byte ceiling also applies across individually valid responses' do
    body = "{}#{' ' * 3_500_000}"
    stub_request(:get, 'https://monitoring.googleapis.com/v3/projects/school-project/timeSeries').to_return(body:)
    transport = Performance::MonitoringTransport.new(auth: -> { 'ephemeral' })
    4.times { assert_empty transport.get('/v3/projects/school-project/timeSeries', []) }
    error = assert_raises(Performance::MonitoringTransport::Error) { transport.get('/v3/projects/school-project/timeSeries', []) }
    assert_equal :partial, error.state
  end
end
