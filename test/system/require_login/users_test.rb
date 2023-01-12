# frozen_string_literal: true

require 'application_system_test_case'
require 'supports/login_assert_helper'

class UsersLoginTest < ApplicationSystemTestCase
  include LoginAssertHelper
  test 'cannot access users list without login' do
    assert_login_required('/users')
  end

  test 'cannot access user detail without login' do
    assert_login_required("/users/#{users(:hatsuno).id}")
  end

  test 'can access user create screen without login' do
    assert_no_login_required('/users/new', 'フィヨルドブートキャンプ参加登録')
  end
end
