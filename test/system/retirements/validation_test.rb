# frozen_string_literal: true

require 'application_system_test_case'

module Retirements
  class ValidationTest < ApplicationSystemTestCase
    setup do
      @delivery_mode = AbstractNotifier.delivery_mode
      AbstractNotifier.delivery_mode = :normal
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/all')
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/admin')
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/mentor')
    end

    teardown do
      AbstractNotifier.delivery_mode = @delivery_mode
    end

    test 'enables retirement regardless of validity of discord id' do
      user = users(:discordinvalid)
      visit_with_auth new_retirement_path, 'discordinvalid'
      find('label', text: 'とても悪い').click
      page.accept_confirm do
        click_on '退会する'
      end
      assert_text '退会処理が完了しました'
      assert_equal Date.current, user.reload.retired_on
      assert_equal '😢 discordinvalidさんが退会しました。', users(:komagata).notifications.last.message
      assert_equal '😢 discordinvalidさんが退会しました。', users(:mentormentaro).notifications.last.message

      login_user 'discordinvalid', 'testtest'
      assert_text '退会したユーザーです'
    end

    test 'enables retirement regardless of validity of X（Twitter） ID' do
      user = users(:twitterinvalid)
      visit_with_auth new_retirement_path, 'twitterinvalid'
      find('label', text: 'とても悪い').click
      page.accept_confirm do
        click_on '退会する'
      end
      assert_text '退会処理が完了しました'
      assert_equal Date.current, user.reload.retired_on
      assert_equal '😢 twitterinvalidさんが退会しました。', users(:komagata).notifications.last.message
      assert_equal '😢 twitterinvalidさんが退会しました。', users(:mentormentaro).notifications.last.message

      login_user 'twitterinvalid', 'testtest'
      assert_text '退会したユーザーです'
    end
  end
end
