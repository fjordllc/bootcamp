# frozen_string_literal: true

require 'test_helper'

class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase
  test 'login user can connect' do
    user = users(:hajime)

    cookies.encrypted[Rails.application.config.session_options[:key]] = { user_id: user.id }
    connect
    assert_equal user.id, connection.current_user.id
  end

  test 'not login user are rejected connection' do
    cookies.encrypted[Rails.application.config.session_options[:key]] = { user_id: '' }
    assert_reject_connection { connect }
  end
end
