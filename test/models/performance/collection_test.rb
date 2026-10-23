# frozen_string_literal: true

require 'test_helper'
require 'supports/mock_env_helper'

class Performance::CollectionTest < ActiveSupport::TestCase
  test 'writer serializes only validated enum fields and numeric values as bare JSON' do
    output = StringIO.new
    writer = Performance::LogWriter.new(output:)
    writer.server(page: 'reports_index', duration_ms: 842.4)
    writer.server(page: 'private@example.invalid', duration_ms: 1)
    writer.server(page: 'reports_index', duration_ms: -1)
    records = output.string.lines.map { |line| JSON.parse(line) }
    assert_equal [{ 'severity' => 'INFO', 'event' => 'bootcamp_performance', 'schema' => 1, 'kind' => 'server',
                    'page' => 'reports_index', 'duration_ms' => 842.4 }], records
  end

  test 'report schema rejects arbitrary nested input and never substitutes zero for missing INP' do
    report = packet
    assert Performance::Report.new(report).valid?
    report['performance_report']['metrics']['INP']['value'] = 0
    assert_not Performance::Report.new(report).valid?
    report['performance_report']['metrics']['INP'] = { 'state' => 'observed', 'value' => '1' }
    assert_not Performance::Report.new(report).valid?
    report['secret'] = 'private@example.invalid'
    assert_not Performance::Report.new(report).valid?
  end

  test 'boundary drops oversized chunked and malformed bodies without calling Rails' do
    app = ->(_env) { flunk 'unsafe body reached Rails' }
    boundary = Performance::CollectorBoundary.new(app)
    ['{"private@example.invalid":', 'x' * 2049].each_with_index do |body, index|
      env = Rack::MockRequest.env_for('/api/performance_reports', method: 'POST', input: body, 'CONTENT_TYPE' => 'application/json')
      env.delete('CONTENT_LENGTH')
      status, = boundary.call(env)
      assert_equal [400, 413][index], status
    end
  end

  private

  def packet
    { 'performance_report' => { 'token' => 'opaque', 'page' => 'reports_index', 'device' => 'mobile', 'metrics' => {
      'LCP' => { 'state' => 'observed', 'value' => 2400 }, 'INP' => { 'state' => 'unobserved' }, 'CLS' => { 'state' => 'observed', 'value' => 0 }
    } } }
  end
end

class Performance::StateTest < ActiveSupport::TestCase
  class MemoryState
    attr_accessor :busy, :failed
    attr_reader :data

    def initialize(data = {})
      @data = data
      @mutex = Mutex.new
    end

    def synchronize(_lock)
      raise Performance::SharedState::Unavailable if failed
      return :busy if busy

      @mutex.synchronize { yield self }
    end

    def read(key)
      raise Performance::SharedState::Unavailable if failed

      data[key]&.deep_dup
    end

    def write(key, value, **_options)
      raise Performance::SharedState::Unavailable if failed

      data[key] = value.deep_dup
      true
    end
  end

  setup do
    @state = MemoryState.new
    @gate = Performance::ReportGate.new(state: @state)
    @now = Time.utc(2026, 10, 20, 12)
    @binding = Digest::SHA256.hexdigest('synthetic-session')
  end

  test 'tickets bind page session and hour and duplicates do not emit another accepted batch' do
    token = issue
    assert_equal :invalid, accept(token, page: 'users_index')
    assert_equal :invalid, @gate.accept(token:, session_binding: 'wrong-session', page: 'reports_index', now: @now)
    assert_equal :accepted, accept(token)
    assert_equal :duplicate, Performance::ReportGate.new(state: @state).accept(token:, session_binding: @binding, page: 'reports_index', now: @now)
    assert_equal :invalid, accept(token, now: @now + 3600)
    assert_equal :invalid, accept('forged')
  end

  test 'rolling session limit never removes live replay markers and resets after sixty seconds' do
    tokens = Array.new(8) { issue }
    tokens.first(6).each { |token| assert_equal :accepted, accept(token) }
    assert_equal :limited, accept(tokens[6], now: @now + 59)
    assert_equal :duplicate, accept(tokens.first, now: @now + 59)
    assert_equal :accepted, accept(tokens[6], now: @now + 60)
    assert @state.read('limited_at')
  end

  test 'sixty issued nonces cannot evict live markers and cache loss invalidates old tickets' do
    tokens = Array.new(60) { issue }
    assert_nil issue
    assert_equal :accepted, accept(tokens.first)
    @state.data.delete('budget')
    assert_equal :unavailable, accept(tokens.last)
    fresh = issue
    assert_equal :invalid, accept(tokens.last)
    assert_equal :accepted, accept(fresh)
    @state.data.delete("session:#{@binding}")
    assert_equal :invalid, accept(fresh)
  end

  test 'global rolling budget is shared across sixty independent session generations' do
    60.times do |index|
      binding = Digest::SHA256.hexdigest("synthetic-#{index}")
      token = @gate.issue(session_binding: binding, page: 'reports_index', now: @now)
      assert_equal :accepted, @gate.accept(token:, session_binding: binding, page: 'reports_index', now: @now)
    end
    token = issue
    assert_equal :limited, accept(token, now: @now + 59)
    assert_equal :accepted, accept(token, now: @now + 60)
  end

  [64, 119].each do |minute|
    test "issuance at minute #{minute} keeps its budget alive without accepted reports" do
      @state = shared_store(ActiveSupport::Cache::MemoryStore.new, Mutex.new)
      @gate = Performance::ReportGate.new(state: @state)
      generation = nil
      travel_to(@now) do
        assert issue
        generation = @state.read('budget').fetch('generation')
      end
      # Keep issuing before expiry, including across a hypothetical fixed two-hour TTL.
      travel_to(@now + 60.minutes) { assert @gate.issue(session_binding: @binding, page: 'reports_index', now: Time.current) } if minute > 65
      token = nil
      travel_to(@now + minute.minutes) do
        token = @gate.issue(session_binding: @binding, page: 'reports_index', now: Time.current)
        assert token
      end
      travel_to(@now + (minute + 2).minutes) do
        assert_equal :accepted, accept(token, now: Time.current)
        assert_equal generation, @state.read('budget').fetch('generation')
        assert_equal :duplicate, accept(token, now: Time.current)
      end
    end
  end

  test 'issuing a ticket preserves existing budget generation and rolling acceptances' do
    assert_equal :accepted, accept(issue)
    budget = @state.read('budget')
    assert issue
    assert_equal budget, @state.read('budget')
  end

  test 'failed budget renewal prevents issuing a new ticket' do
    token = issue
    original_write = @state.method(:write)
    @state.define_singleton_method(:write) do |key, value, **options|
      raise Performance::SharedState::Unavailable if key == 'budget'

      original_write.call(key, value, **options)
    end
    assert_nil issue
    assert_equal :unavailable, accept(token)
  end

  test 'two independent stores share SQL lock exclusion and cannot accept a concurrent replay' do
    backend = ActiveSupport::Cache::MemoryStore.new
    mutex = Mutex.new
    stores = Array.new(2) { shared_store(backend, mutex) }
    gates = stores.map { |store| Performance::ReportGate.new(state: store) }
    token = gates.first.issue(session_binding: @binding, page: 'reports_index', now: @now)
    entered = Queue.new
    release = Queue.new
    result = nil
    worker = Thread.new do
      stores.first.synchronize(1) do
        entered << true
        release.pop
        # PostgreSQL advisory locks are reentrant on the checked-out connection.
        result = :held
      end
    end
    entered.pop
    assert_equal :busy, gates.last.accept(token:, session_binding: @binding, page: 'reports_index', now: @now)
    release << true
    worker.join
    assert_equal :held, result
    assert_equal :accepted, gates.first.accept(token:, session_binding: @binding, page: 'reports_index', now: @now)
    assert_equal :duplicate, gates.last.accept(token:, session_binding: @binding, page: 'reports_index', now: @now)
  ensure
    release << true if worker&.alive?
    worker&.join
  end

  test 'lock contention and cache failure omit instrumentation and fail closed' do
    @state.busy = true
    assert_nil issue
    @state.busy = false
    token = issue
    @state.failed = true
    assert_nil issue
    assert_equal :unavailable, accept(token)
  end

  test 'shared store rejects nil writes and releases advisory lock even when work raises' do
    cache = Object.new
    cache.define_singleton_method(:write) { |*_args, **_options| nil }
    cache.define_singleton_method(:read) { |*_args| nil }
    sql = []
    connection = Object.new
    connection.define_singleton_method(:transaction) { |**_options, &block| block.call }
    connection.define_singleton_method(:execute) { |query| sql << query }
    connection.define_singleton_method(:select_value) do |query|
      sql << query
      true
    end
    pool = Object.new
    pool.define_singleton_method(:with_connection) { |&block| block.call(connection) }
    shared = Performance::SharedState.new(cache:, pool:)
    assert_nil shared.read('missing')
    assert_raises(Performance::SharedState::Unavailable) { shared.write('bad', 1) }
    assert_raises(ArgumentError) { shared.synchronize(2) { raise ArgumentError } }
    assert_includes sql, 'SELECT pg_advisory_unlock(1792555, 2)'
    assert_includes sql, "SET LOCAL statement_timeout = '1000ms'"
  end

  test 'shared snapshot caches failure for five minutes and cache unavailability makes no Google calls' do
    config = configured
    calls = 0
    reader = Object.new
    reader.define_singleton_method(:read) do |**_options|
      calls += 1
      Performance::MetricSpecs::SPECS.keys.index_with { { state: :permission_error, groups: {} } }
    end
    first = Performance::Snapshot.fetch(now: @now, config:, shared: @state, reader:)
    second = Performance::Snapshot.fetch(now: @now + 299, config:, shared: @state, reader:)
    assert_equal 1, calls
    assert_equal first.fetched_at, second.fetched_at
    @state.busy = true
    assert_equal first.fetched_at, Performance::Snapshot.fetch(now: @now + 299, config:, shared: @state, reader:).fetched_at
    @state.busy = false
    assert_nil second.summary.rating
    assert_equal :permission_error, second.pages.first[:server].state
    Performance::Snapshot.fetch(now: @now + 301, config:, shared: @state, reader:)
    assert_equal 2, calls
    @state.failed = true
    assert_equal :unavailable, Performance::Snapshot.fetch(now: @now + 602, config:, shared: @state, reader:).state
    assert_equal 2, calls
  end

  test 'stopping collection cannot reuse an active cached snapshot or call Google' do
    config = configured
    active = Performance::Snapshot.new(state: :ready, now: @now, config:)
    @state.write("snapshot:#{config.identity}", active)
    paused_config = Performance::Configuration.new('PERFORMANCE_DASHBOARD_ENABLED' => 'true',
                                                   'PERFORMANCE_PROJECT_ID' => 'school-project',
                                                   'PERFORMANCE_CLOUD_RUN_SERVICE' => 'bootcamp', 'PERFORMANCE_CLOUD_RUN_REGION' => 'asia-northeast1',
                                                   'PERFORMANCE_COLLECTION_STARTED_AT' => '2026-10-01T00:00:00Z')
    @state.failed = true
    snapshot = Performance::Snapshot.fetch(now: @now, config: paused_config, shared: @state)
    assert_equal :paused, snapshot.state
    assert_nil snapshot.summary.rating
    assert_equal '計測を停止しています', snapshot.label
    assert_equal :paused, snapshot.pages.first[:server].state
  end

  test 'failed initial cache write prevents Google calls and failed final write retains neutral cooldown' do
    calls = 0
    reader = Object.new
    reader.define_singleton_method(:read) do |**_options|
      calls += 1
      Performance::MetricSpecs::SPECS.keys.index_with { { state: :permission_error, groups: {} } }
    end
    @state.define_singleton_method(:write) { |*_args, **_options| raise Performance::SharedState::Unavailable }
    snapshot = Performance::Snapshot.fetch(now: @now, config: configured, shared: @state, reader:)
    assert_equal :unavailable, snapshot.state
    assert_equal 0, calls

    state = MemoryState.new
    original_write = state.method(:write)
    writes = 0
    state.define_singleton_method(:write) do |*args, **options|
      writes += 1
      raise Performance::SharedState::Unavailable if writes > 1

      original_write.call(*args, **options)
    end
    snapshot = Performance::Snapshot.fetch(now: @now, config: configured, shared: state, reader:)
    assert_equal :unavailable, snapshot.state
    assert_equal 1, calls
    snapshot = Performance::Snapshot.fetch(now: @now + 299, config: configured, shared: state, reader:)
    assert_equal :refreshing, snapshot.state
    assert_nil snapshot.summary.rating
    assert_equal 1, calls
  end

  test 'snapshot losing lock is neutral and unconfigured never calls shared state' do
    @state.busy = true
    assert_equal :refreshing, Performance::Snapshot.fetch(now: @now, config: configured, shared: @state).state
    @state.failed = true
    assert_equal :unconfigured, Performance::Snapshot.fetch(now: @now, config: Performance::Configuration.new({}), shared: @state).state
  end

  private

  def shared_store(backend, mutex)
    cache = Object.new
    cache.define_singleton_method(:read) { |key| backend.read(key) }
    cache.define_singleton_method(:write) { |key, value, **options| backend.write(key, value, **options) }
    pool = Object.new
    pool.define_singleton_method(:with_connection) do |&block|
      connection = Object.new
      connection.define_singleton_method(:transaction) { |**_options, &work| work.call }
      connection.define_singleton_method(:execute) { |_query| nil }
      connection.define_singleton_method(:select_value) do |query|
        query.include?('try_advisory_lock') ? mutex.try_lock : mutex.unlock
      end
      block.call(connection)
    end
    Performance::SharedState.new(cache:, pool:)
  end

  def issue
    @gate.issue(session_binding: @binding, page: 'reports_index', now: @now)
  end

  def accept(token, page: 'reports_index', now: @now)
    @gate.accept(token:, session_binding: @binding, page:, now:)
  end

  def configured
    Performance::Configuration.new('PERFORMANCE_COLLECTION_ENABLED' => 'true', 'PERFORMANCE_DASHBOARD_ENABLED' => 'true',
                                   'PERFORMANCE_PROJECT_ID' => 'school-project',
                                   'PERFORMANCE_CLOUD_RUN_SERVICE' => 'bootcamp', 'PERFORMANCE_CLOUD_RUN_REGION' => 'asia-northeast1',
                                   'PERFORMANCE_COLLECTION_STARTED_AT' => '2026-10-01T00:00:00Z')
  end
end

class Performance::SharedStateFactoryTest < ActiveSupport::TestCase
  test 'concurrent default construction reuses one dedicated cache with configured options' do
    previous_cache = Performance::SharedState.instance_variable_get(:@default_cache)
    Performance::SharedState.instance_variable_set(:@default_cache, nil)
    calls = Queue.new
    ready = Queue.new
    start = Queue.new
    pool = Object.new
    factory = lambda do |**options|
      calls << options
      Thread.pass
      ActiveSupport::Cache::MemoryStore.new
    end
    SolidCache::Store.stub(:new, factory) do
      workers = Array.new(8) do
        Thread.new do
          ready << true
          start.pop
          Performance::SharedState.new(pool:)
        end
      end
      workers.length.times { ready.pop }
      workers.length.times { start << true }
      stores = workers.map(&:value)
      assert_equal 1, calls.size
      assert_equal SolidCache.configuration.store_options, calls.pop
      cache = stores.first.instance_variable_get(:@cache)
      stores.each { |store| assert_same cache, store.instance_variable_get(:@cache) }
      assert_not_same Rails.cache, cache
    ensure
      workers&.each(&:join)
    end
  ensure
    Performance::SharedState.instance_variable_set(:@default_cache, previous_cache)
  end

  test 'explicit cache injection bypasses the default factory' do
    cache = ActiveSupport::Cache::MemoryStore.new
    factory = ->(**_options) { flunk 'injected cache constructed a default store' }
    SolidCache::Store.stub(:new, factory) do
      shared = Performance::SharedState.new(cache:, pool: Object.new)
      assert_same cache, shared.instance_variable_get(:@cache)
    end
  end
end

class Performance::WriterLifecycleTest < ActiveSupport::TestCase
  include MockEnvHelper

  test 'browser writer retains only finite scalar observations and explicit availability' do
    output = StringIO.new
    writer = Performance::LogWriter.new(output:)
    writer.browser(page: 'reports_index', device: 'desktop', metrics: {
                     'LCP' => { 'state' => 'observed', 'value' => 1 }, 'INP' => { 'state' => 'unsupported' }, 'CLS' => { 'state' => 'observed', 'value' => 0 }
                   })
    assert_equal 3, output.string.lines.length
    assert(output.string.lines.all? { |line| line.bytesize < 512 })
    assert_equal(%w[observed unsupported observed], output.string.lines.map { |line| JSON.parse(line)['state'] })
  end

  test 'subscriber reinstall emits exactly one successful eligible response and ignores failures' do
    output = StringIO.new
    writer = Performance::LogWriter.new(output:)
    payload = { performance_eligible: true, performance_page: 'reports_index', method: 'GET', format: :html, status: 200,
                params: { secret: 'private@example.invalid' } }
    Performance::LogWriter.install
    Performance::LogWriter.install
    mock_env('PERFORMANCE_COLLECTION_ENABLED' => 'true') do
      Performance::LogWriter.stub(:new, writer) do
        ActiveSupport::Notifications.instrument('process_action.action_controller', payload)
        [{ status: 302 }, { status: 500 }, { method: 'POST' }, { format: :json }, { performance_eligible: false },
         { exception: %w[Error secret] }].each do |change|
          ActiveSupport::Notifications.instrument('process_action.action_controller', payload.merge(change))
        end
      end
    end
    assert_equal 1, output.string.lines.length
    record = JSON.parse(output.string)
    assert_operator record['duration_ms'], :>=, 0
    assert_not_includes output.string, 'private@example.invalid'
  end

  test 'writer IO failure loses sample safely and sanitizes throttled warning' do
    output = Object.new
    output.define_singleton_method(:write) { |_data| raise IOError, 'private@example.invalid' }
    warnings = StringIO.new
    Performance::LogWriter.instance_variable_set(:@warned_at, nil)
    Rails.stub(:logger, ActiveSupport::Logger.new(warnings)) do
      2.times { assert_not Performance::LogWriter.new(output:).server(page: 'reports_index', duration_ms: 1) }
    end
    assert_equal 1, warnings.string.lines.length
    assert_not_includes warnings.string, 'private@example.invalid'
  end
end
