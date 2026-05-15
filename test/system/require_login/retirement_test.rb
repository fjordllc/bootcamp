# frozen_string_literal: true

require 'application_system_test_case'
require 'supports/login_assert_helper'

class RetirementLoginTest < ApplicationSystemTestCase
  include LoginAssertHelper

  setup do
    Capybara.reset_sessions!
  rescue Net::ReadTimeout
    # セッションリセット時のタイムアウトは無視して続行
  end

  test 'can access retirement complete screen without login' do
    assert_no_login_required('/retirement', '退会処理が完了しました')
  end

  test 'cannot access retirement/new without login' do
    assert_login_required('/retirement/new')
  end
end
