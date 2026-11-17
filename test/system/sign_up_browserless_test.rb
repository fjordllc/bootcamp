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

  test 'job seeker option is shown for student' do
    visit '/users/new'
    assert_selector 'form[name=user]'
    assert_selector "input[name='user[job_seeker]']", visible: :all
  end
end
