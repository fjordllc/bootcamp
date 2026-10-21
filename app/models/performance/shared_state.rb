# frozen_string_literal: true

module Performance
  class SharedState
    class Unavailable < StandardError; end

    @default_cache_mutex = Mutex.new

    def self.default_cache
      @default_cache_mutex.synchronize do
        @default_cache ||= SolidCache::Store.new(**SolidCache.configuration.store_options)
      end
    end

    def initialize(cache: nil, pool: nil)
      @cache = cache || self.class.default_cache
      @pool = pool || SolidCache::Record.connection_pool
    end

    def synchronize(lock)
      @pool.with_connection do |connection|
        acquired = bounded(connection) { connection.select_value("SELECT pg_try_advisory_lock(1792555, #{Integer(lock)})") }
        return :busy unless acquired

        begin
          yield self
        ensure
          bounded(connection) { connection.select_value("SELECT pg_advisory_unlock(1792555, #{Integer(lock)})") }
        end
      end
    rescue ActiveRecord::ActiveRecordError, IOError, TypeError
      raise Unavailable
    end

    def read(key)
      access { @cache.read("performance:v1:#{key}") }
    end

    def write(key, value, expires_in: 65.minutes)
      success = access { @cache.write("performance:v1:#{key}", value, expires_in:) }
      raise Unavailable unless success

      true
    end

    private

    def access(&block)
      @pool.with_connection { |connection| bounded(connection, &block) }
    rescue ActiveRecord::ActiveRecordError, IOError, TypeError
      raise Unavailable
    end

    def bounded(connection)
      connection.transaction(requires_new: true) do
        connection.execute("SET LOCAL statement_timeout = '1000ms'")
        yield
      end
    end
  end
end
