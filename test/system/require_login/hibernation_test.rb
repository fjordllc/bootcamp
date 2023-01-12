# frozen_string_literal: true

require 'application_system_test_case'
require 'supports/login_assert_helper'

class HibernationLoginTest < ApplicationSystemTestCase
  include LoginAssertHelper
  test 'can access hibernating complete screen without login' do
    assert_no_login_required('/hibernation', '休会処理が完了しました')
  end

  test 'cannot access hibernate/new without login' do
    assert_login_required('/hibernation/new')
  end
end
