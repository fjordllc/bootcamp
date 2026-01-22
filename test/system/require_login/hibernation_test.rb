# frozen_string_literal: true

require 'application_system_test_case'
require 'supports/login_assert_helper'

class HibernationLoginTest < ApplicationSystemTestCase
  include LoginAssertHelper

  setup do
    Capybara.reset_sessions!
  rescue Net::ReadTimeout
    # セッションリセット時のタイムアウトは無視して続行
  end

  test 'can access hibernating complete screen without login' do
    assert_no_login_required('/hibernation', '休会手続きが完了しました')
  end

  test 'cannot access hibernate/new without login' do
    assert_login_required('/hibernation/new')
  end
end
