# frozen_string_literal: true

require 'digest'

module Mcp
  # Serializes increments of a cache-backed rate counter so concurrent
  # requests cannot all observe a missing key and each store count=1.
  #
  # Solid Cache 1.0.10 increments counters with lock_and_write, whose
  # SELECT ... FOR UPDATE cannot lock a row that does not exist yet, so
  # simultaneous first increments of a new key race. To close that gap,
  # each increment runs inside a transaction on the application's
  # ActiveRecord connection that first takes a PostgreSQL
  # transaction-level advisory lock derived deterministically from the
  # complete counter key. The lock is released automatically when the
  # transaction commits or rolls back, including when increment raises.
  class RateLimitCounter
    def self.increment(key)
      ActiveRecord::Base.transaction do
        acquire_advisory_lock(key)
        Rails.cache.increment(key, 1, expires_in: 2.minutes, initial: 0)
      end
    end

    def self.acquire_advisory_lock(key)
      # The bind carries only a signed 64-bit integer derived from the
      # key, never the untrusted key string itself.
      ActiveRecord::Base.connection.execute(
        ActiveRecord::Base.sanitize_sql_array(['SELECT pg_advisory_xact_lock(?)', lock_id_for(key)])
      )
    end
    private_class_method :acquire_advisory_lock

    # Signed 64-bit integer derived from the SHA256 digest of the key, so
    # the same key always maps to the same advisory lock.
    def self.lock_id_for(key)
      Digest::SHA256.digest(key.to_s).unpack1('q>')
    end
    private_class_method :lock_id_for
  end
end
