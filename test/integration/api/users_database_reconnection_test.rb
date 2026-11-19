# frozen_string_literal: true

require 'test_helper'

class API::UsersDatabaseReconnectionTest < ActionDispatch::IntegrationTest
  self.use_transactional_tests = false

  class ServerSideConnectionCloser
    def initialize(sql_pattern)
      @sql_pattern = sql_pattern
      @attempted = false
      @closed = false
    end

    def closed?
      @closed
    end

    def start(_name, _id, payload)
      return if @attempted || !payload[:sql].match?(@sql_pattern)

      @attempted = true
      @closed = terminate_backend_of(payload[:connection])
    end

    def finish(_name, _id, _payload); end

    private

    def terminate_backend_of(connection)
      backend_pid = Integer(connection.select_value('SELECT pg_backend_pid()'))
      pool = connection.pool
      another_connection = pool.checkout
      another_connection.select_value("SELECT pg_terminate_backend(#{backend_pid})")
    ensure
      pool.checkin(another_connection) if another_connection
    end
  end

  test 'GET /api/users/1234.json returns mentor memos when the server closes the database connection just before reading them' do
    token = create_token('komagata', 'testtest')
    user = users(:kimura)
    expected_contents = [mentor_memos(:kimura).content, mentor_memos(:migrated_kimura).content]
    connection_closer = ServerSideConnectionCloser.new(/FROM "mentor_memos"/)

    ActiveSupport::Notifications.subscribed(connection_closer, 'sql.active_record') do
      get api_user_path(user.id, format: :json), headers: { 'Authorization' => "Bearer #{token}" }
    end

    assert connection_closer.closed?
    assert_response :ok
    assert_equal(expected_contents, response.parsed_body['mentor_memos'].map { |memo| memo['content'] })
  end
end
