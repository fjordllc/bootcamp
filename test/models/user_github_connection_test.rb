# frozen_string_literal: true

require 'test_helper'

class UserGithubConnectionTest < ActiveSupport::TestCase
  setup do
    @user = users(:kimura)
    @user.update!(github_id: '12345', github_account: 'github_kimura', github_collaborator: true)
    @connection = UserGithubConnection.new(@user)
  end

  test 'connect saves the id and account while preserving collaborator status' do
    @connection.connect!(uid: '67890', nickname: 'new_account')

    assert_equal '67890', @user.reload.github_id
    assert_equal 'new_account', @user.github_account
    assert @user.github_collaborator?
  end

  test 'disconnect only clears the id' do
    assert @connection.disconnect

    assert_nil @user.reload.github_id
    assert_equal 'github_kimura', @user.github_account
    assert @user.github_collaborator?
  end

  test 'clear_data clears all three GitHub fields' do
    assert @connection.clear_data

    assert_nil @user.reload.github_id
    assert_nil @user.github_account
    assert_not @user.github_collaborator?
  end

  test 'connect raises on validation failure without persisting the connection' do
    @user.login_name = nil

    assert_raises ActiveRecord::RecordInvalid do
      @connection.connect!(uid: '67890', nickname: 'new_account')
    end
    assert_equal '12345', @user.reload.github_id
  end

  test 'disconnect and clear_data return false on validation failure' do
    @user.login_name = nil
    assert_not @connection.disconnect
    assert_not @connection.clear_data

    assert_equal '12345', @user.reload.github_id
    assert_equal 'github_kimura', @user.github_account
    assert @user.github_collaborator?
  end
end
