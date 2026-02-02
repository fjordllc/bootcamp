# frozen_string_literal: true

require 'application_system_test_case'
require 'supports/login_assert_helper'

class UsersLoginTest < ApplicationSystemTestCase
  include LoginAssertHelper

  setup do
    Capybara.reset_sessions!
  rescue Net::ReadTimeout
    # セッションリセット時のタイムアウトは無視して続行
  end

  test 'cannot access users list without login' do
    assert_login_required('/users')
  end

  test 'can access user create screen without login' do
    visit '/users/new'
    assert_selector 'h1.auth-form__title', text: 'FBC参加登録'
    assert_no_text 'ログインしてください'
  end
end
