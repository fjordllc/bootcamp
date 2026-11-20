# frozen_string_literal: true

require 'test_helper'

class MentorMemoTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  test '.oldest_first orders memos from oldest to newest and puts memos without created_at last' do
    assert_equal [mentor_memos(:kimura), mentor_memos(:newer_kimura), mentor_memos(:migrated_kimura)],
                 users(:kimura).mentor_memos.oldest_first.to_a
  end

  test '.oldest_first loads memos after the database server closed the connection' do
    expected_memos = [mentor_memos(:kimura), mentor_memos(:newer_kimura), mentor_memos(:migrated_kimura)]
    memos = users(:kimura).mentor_memos.oldest_first

    close_freshly_leased_connection_from_server

    assert_equal expected_memos, memos.to_a
  end

  private

  def close_freshly_leased_connection_from_server
    pool = ActiveRecord::Base.connection_pool
    pool.release_connection
    backend_pid = Integer(pool.lease_connection.select_value('SELECT pg_backend_pid()'))
    other_connection = pool.checkout
    other_connection.select_value("SELECT pg_terminate_backend(#{backend_pid})")
    Timeout.timeout(5) do
      sleep 0.01 while other_connection.select_value("SELECT 1 FROM pg_stat_activity WHERE pid = #{backend_pid}")
    end
  ensure
    pool.checkin(other_connection) if other_connection
  end
end
