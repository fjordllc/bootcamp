# frozen_string_literal: true

require 'browserless_system_test_case'

class SignUpBrowserlessTest < BrowserlessSystemTestCase
  setup do
    @bot_token = Discord::Server.authorize_token
    Discord::Server.authorize_token = nil
    Capybara.reset_sessions!
  rescue Net::ReadTimeout
    # セッションリセット時のタイムアウトは無視して続行
  end

  teardown do
    Discord::Server.authorize_token = @bot_token
  end

  test 'student sign up asks only what is needed to start trial' do
    visit '/users/new'
    assert_selector 'form[name=user]'
    %w[description job os job_seeker after_graduation_hope password_confirmation].each do |attribute|
      assert_no_selector "[name='user[#{attribute}]']", visible: :all
    end
    assert_selector "input[name='user[login_name]']"
    assert_selector "input[name='user[name_kana]']"
  end
end
