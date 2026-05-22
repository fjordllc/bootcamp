# frozen_string_literal: true

require 'application_system_test_case'

module SignUp
  class ValidationTest < ApplicationSystemTestCase
    setup do
      @bot_token = Discord::Server.authorize_token
      Discord::Server.authorize_token = nil
      Capybara.reset_sessions!
    rescue Net::ReadTimeout
      page.driver.quit
    end

    teardown do
      Discord::Server.authorize_token = @bot_token
    end

    test 'hidden input learning time frames table' do
      visit '/users/new'
      assert_no_selector ".form-item.a-form-label[for='user_learning_time_frames']", text: '主な活動予定時間'
    end
  end
end
