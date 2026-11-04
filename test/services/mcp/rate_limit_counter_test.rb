# frozen_string_literal: true

require 'test_helper'

# Regression tests for Mcp::RateLimitCounter using the real Solid Cache
# store on the test PostgreSQL database.
#
# This class is intentionally nontransactional and loads no fixtures:
# worker threads must see each other's committed cache rows, and the main
# thread must not retain a fixture transaction that holds an advisory
# lock while a worker needs it. Each test cleans up only its own random
# cache key.
class McpRateLimitCounterTest < ActiveSupport::TestCase
  self.use_transactional_tests = false
  self.fixture_table_names = []

  setup do
    @previous_cache = Rails.cache
    @cache = SolidCache::Store.new
    Rails.cache = @cache
    @key = "mcp-rate-limit-counter-test:#{SecureRandom.uuid}"
  end

  teardown do
    @cache.delete(@key)
    Rails.cache = @previous_cache
  end

  test 'increment starts at one and counts up sequentially' do
    assert_nil @cache.read(@key)

    assert_equal 1, Mcp::RateLimitCounter.increment(@key)
    assert_equal 2, Mcp::RateLimitCounter.increment(@key)
    assert_equal 2, @cache.read(@key)
  end

  test 'concurrent first increments of a missing key are serialized' do
    assert_nil @cache.read(@key)

    gate = Queue.new
    threads = Array.new(4) do
      Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          gate.pop
          Mcp::RateLimitCounter.increment(@key)
        end
      end
    end
    threads.size.times { gate.push(true) }
    results = threads.map(&:value)

    # Without the advisory lock, Solid Cache's SELECT ... FOR UPDATE
    # cannot lock the missing row and every thread reads nil then stores
    # count=1. Serialized, each increment observes the previous one.
    assert_equal [1, 2, 3, 4], results.sort
    assert_equal 4, @cache.read(@key)
  end

  test 'releases the advisory lock when the cache increment raises' do
    @cache.stub(:increment, ->(*) { raise IOError, 'cache store unavailable' }) do
      assert_raises(IOError) { Mcp::RateLimitCounter.increment(@key) }
    end

    # The rolled-back transaction must have released the transaction
    # advisory lock, so an independent session can acquire it
    # immediately. The try-lock runs in autocommit and retains nothing.
    lock_id = Digest::SHA256.digest(@key).unpack1('q>')
    acquired = Thread.new do
      ActiveRecord::Base.connection_pool.with_connection do |connection|
        connection.select_value("SELECT pg_try_advisory_xact_lock(#{lock_id})")
      end
    end.value
    assert acquired

    # And the counter still works afterwards.
    assert_equal 1, Mcp::RateLimitCounter.increment(@key)
  end
end
