# frozen_string_literal: true

require 'test_helper'

class Performance::PolicyTest < ActiveSupport::TestCase
  test 'twenty observations are required separately for each metric' do
    assert_equal :insufficient, cell(19, [0, 100]).state
    assert_equal :good, cell(20, [0, 100]).rating
    assert_equal :no_data, cell(0, nil).state
  end

  test 'threshold boundary intervals remain neutral' do
    { 'server' => [500, 1000], 'LCP' => [2500, 4000], 'INP' => [200, 500], 'CLS' => [0.1, 0.25] }.each do |metric, thresholds|
      thresholds.each do |threshold|
        result = Performance::Snapshot::Cell.new(metric:, count: 20, interval: [threshold, threshold * 1.1])
        assert_nil result.rating
        assert_equal :boundary, result.state
      end
    end
  end

  test 'good known values cannot hide missing data and poor known values remain visible' do
    good = cell(20, [0, 100])
    missing = cell(0, nil)
    summary = Performance::Snapshot::Summary.new([good, missing])
    assert_nil summary.rating
    assert_equal 1, summary.unknown_count
    assert_equal :poor, Performance::Snapshot::Summary.new([cell(20, [1250, 1500]), missing]).rating
  end

  private

  def cell(count, interval)
    Performance::Snapshot::Cell.new(metric: 'server', count:, interval:)
  end
end

class Performance::ConfigurationTest < ActiveSupport::TestCase
  test 'registry exposes only fixed controller action pairs' do
    assert_equal 'reports_show', Performance::Pages.key_for('reports', 'show')
    assert_nil Performance::Pages.key_for('api/reports', 'show')
    assert_nil Performance::Pages.key_for('reports', 'destroy')
    assert_equal 10, Performance::Pages::REGISTRY.length
  end

  test 'configuration is strictly disabled without fixed valid deployment values' do
    assert_not Performance::Configuration.new({}).collection?
    assert_not Performance::Configuration.new('PERFORMANCE_COLLECTION_ENABLED' => '1').collection?
    assert Performance::Configuration.new('PERFORMANCE_COLLECTION_ENABLED' => 'true').collection?
    config = Performance::Configuration.new('PERFORMANCE_DASHBOARD_ENABLED' => 'true', 'PERFORMANCE_PROJECT_ID' => 'injected" OR metric.type=*',
                                            'PERFORMANCE_CLOUD_RUN_SERVICE' => 'service', 'PERFORMANCE_CLOUD_RUN_REGION' => 'asia-northeast1',
                                            'PERFORMANCE_COLLECTION_STARTED_AT' => '2026-01-01T00:00:00Z')
    assert_not config.configured?
    assert_includes config.identity, 'service'
    assert_not config.valid_identity?
  end

  test 'five templates share exact units buckets label extractors and page enum' do
    config = Performance::Configuration.new('PERFORMANCE_PROJECT_ID' => 'school-project', 'PERFORMANCE_CLOUD_RUN_SERVICE' => 'school',
                                            'PERFORMANCE_CLOUD_RUN_REGION' => 'asia-northeast1')
    assert config.valid_identity?
    Performance::MetricSpecs::SPECS.each do |metric, spec|
      template = Performance::MetricSpecs.template(metric, config)
      assert_equal spec[:name], template[:name]
      assert_equal spec[:unit], template[:metricDescriptor][:unit]
      assert_equal Performance::MetricSpecs.labels(metric), template[:labelExtractors].keys
      Performance::Pages::REGISTRY.each_key { |page| assert_includes template[:filter], "jsonPayload.page=\"#{page}\"" }
      if metric == 'coverage'
        assert_not template.key?(:valueExtractor)
        assert_not template.key?(:bucketOptions)
        Performance::Pages::STATES.each { |state| assert_includes template[:filter], "jsonPayload.state=\"#{state}\"" }
      else
        assert_equal spec[:bounds], template[:bucketOptions][:explicitBuckets][:bounds]
      end
    end
  end
end

class Performance::DisplayPolicyTest < ActiveSupport::TestCase
  test 'each Google threshold uses entire interval and neighboring categories remain distinct' do
    { 'server' => [500, 1000], 'LCP' => [2500, 4000], 'INP' => [200, 500], 'CLS' => [0.1, 0.25] }.each do |metric, (good, poor)|
      assert_equal :good, Performance::Snapshot::Cell.new(metric:, count: 20, interval: [good * 0.9, good]).rating
      assert_equal :attention, Performance::Snapshot::Cell.new(metric:, count: 20, interval: [good * 1.1, poor]).rating
      assert_equal :poor, Performance::Snapshot::Cell.new(metric:, count: 20, interval: [poor * 1.1, nil]).rating
      assert_nil Performance::Snapshot::Cell.new(metric:, count: 20, interval: [good * 0.9, good * 1.1]).rating
    end
  end

  test 'ranges labels percentiles and ordering expose uncertainty without manufacturing an estimate' do
    cell = Performance::Snapshot::Cell.new(metric: 'LCP', count: 20, interval: [2250, 2500])
    assert_equal '2.25–2.50 秒', cell.range
    assert_equal '良好', cell.label
    assert_equal 75, cell.percentile
    assert_equal 'ms', cell.unit
    assert_equal 20, cell.sample_count
    overflow = Performance::Snapshot::Cell.new(metric: 'server', count: 20, interval: [60_000, nil])
    assert_equal '60.00 秒以上', overflow.range
    assert_equal 95, overflow.percentile
    assert_equal '—', Performance::Snapshot::Cell.new(metric: 'CLS').range
    poor = Performance::Snapshot::Summary.new([overflow])
    good = Performance::Snapshot::Summary.new([cell])
    unknown = Performance::Snapshot::Summary.new([Performance::Snapshot::Cell.new(metric: 'CLS')])
    assert_operator poor.sort_order, :<, unknown.sort_order
    assert_operator unknown.sort_order, :<, good.sort_order
    assert_equal '要改善', poor.label
    assert_equal 1, poor.known_count
    assert_equal 1, poor.expected_count
    assert_equal :poor, poor.worst_known
  end
end

class Performance::DocumentedSpecsTest < ActiveSupport::TestCase
  test 'operator JSON is generated from the same five immutable metric specs' do
    config = Performance::Configuration.new('PERFORMANCE_PROJECT_ID' => 'PROJECT_ID', 'PERFORMANCE_CLOUD_RUN_SERVICE' => 'SERVICE',
                                            'PERFORMANCE_CLOUD_RUN_REGION' => 'REGION')
    templates = Rails.root.join('docs/admin-performance.md').read.scan(/```json\n(.*?)\n```/m).map { |match| JSON.parse(match.first) }
    expected = Performance::MetricSpecs::SPECS.keys.map { |metric| JSON.parse(JSON.generate(Performance::MetricSpecs.template(metric, config))) }
    assert_equal expected, templates
  end
end

class Performance::SnapshotPolicyTest < ActiveSupport::TestCase
  setup do
    @now = Time.utc(2026, 10, 21, 12, 30)
    @config = Performance::Configuration.new('PERFORMANCE_COLLECTION_ENABLED' => 'true', 'PERFORMANCE_DASHBOARD_ENABLED' => 'true',
                                             'PERFORMANCE_PROJECT_ID' => 'school-project', 'PERFORMANCE_CLOUD_RUN_SERVICE' => 'school',
                                             'PERFORMANCE_CLOUD_RUN_REGION' => 'asia-northeast1', 'PERFORMANCE_COLLECTION_STARTED_AT' => '2026-01-01T00:00:00Z')
  end

  test 'complete good requires all seventy independently judged cells and matching received counts' do
    snapshot = Performance::Snapshot.new(state: :ready, now: @now, config: @config).populate(populations)
    assert_equal :ready, snapshot.state
    assert_equal :good, snapshot.summary.rating
    assert_equal 70, snapshot.summary.known_count
    assert_equal 0, snapshot.summary.unknown_count
    assert_equal Time.utc(2026, 10, 21, 12), snapshot.window[:end]
    assert_equal Time.utc(2026, 10, 20, 12), snapshot.window[:start]
    assert_equal @now, snapshot.fetched_at
    assert_equal @now + 5.minutes, snapshot.valid_until
  end

  test 'counter mismatch and missing metric preserve poor known status and rank poor page first' do
    results = populations
    spec = Performance::MetricSpecs::SPECS.fetch('server')
    counts = Array.new(spec[:bounds].length + 1, 0)
    counts[-1] = 20
    results['server'][:groups][['users_show']] = Performance::Histogram.new(bounds: spec[:bounds], counts:)
    results['coverage'][:groups][%w[reports_index desktop LCP observed]] = 19
    results['INP'] = { state: :missing_metric, groups: {} }
    snapshot = Performance::Snapshot.new(state: :ready, now: @now, config: @config).populate(results)
    assert_equal :poor, snapshot.summary.rating
    assert_equal 'users_show', snapshot.pages.first[:key]
    assert_operator snapshot.summary.unknown_count, :>, 0
    page = snapshot.pages.find { |entry| entry[:key] == 'reports_index' }
    assert_equal :partial, page[:browser]['desktop']['LCP'].state
    assert_nil page[:browser]['desktop']['LCP'].rating
    assert_equal :missing_metric, page[:browser]['desktop']['INP'].state
  end

  test 'cutover period and collection limits cannot create all-good assurance' do
    env = { 'PERFORMANCE_COLLECTION_STARTED_AT' => '2026-10-21T00:00:00Z' }
    partial_config = Performance::Configuration.new(env)
    snapshot = Performance::Snapshot.new(state: :ready, now: @now, config: partial_config).populate(populations)
    assert_equal :partial, snapshot.state
    assert_nil snapshot.summary.rating
    range = { 'first' => (@now - 2.hours).to_i, 'last' => @now.to_i }
    snapshot = Performance::Snapshot.new(state: :ready, now: @now, config: @config).populate(populations, limited_at: range)
    assert snapshot.limited
    assert_nil snapshot.summary.rating
  end

  private

  def populations
    results = Performance::MetricSpecs::SPECS.keys.index_with { { state: :ready, groups: {} } }
    Performance::Pages::REGISTRY.each_key do |page|
      %w[server LCP INP CLS].each do |metric|
        spec = Performance::MetricSpecs::SPECS.fetch(metric)
        histogram = Performance::Histogram.new(bounds: spec[:bounds], counts: [0, 20])
        if metric == 'server'
          results[metric][:groups][[page]] = histogram
        else
          Performance::Pages::DEVICES.each do |device|
            results[metric][:groups][[page, device]] = histogram
            results['coverage'][:groups][[page, device, metric, 'observed']] = 20
          end
        end
      end
    end
    results
  end
end
