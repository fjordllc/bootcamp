# frozen_string_literal: true

require 'application_system_test_case'
require 'supports/login_assert_helper'

class ArticlesLoginTest < ApplicationSystemTestCase
  include LoginAssertHelper

  setup do
    Capybara.reset_sessions!
  rescue Net::ReadTimeout
    # セッションリセット時のタイムアウトは無視して続行
  end

  test 'can access articles without login' do
    assert_no_login_required('/articles', 'ブログ')
  end

  test 'can access article detail without login' do
    assert_no_login_required("/articles/#{articles(:article1).id}", articles(:article1).title)
  end
end
