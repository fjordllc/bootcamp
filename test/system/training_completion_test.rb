# frozen_string_literal: true

require 'application_system_test_case'

class TrainingCompletionTest < ApplicationSystemTestCase
  setup do
    @user = users(:kensyu)
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
    travel_to Time.current
    stub_request(:post, 'https://discord.com/api/webhooks/0123456789/all')
    stub_request(:post, 'https://discord.com/api/webhooks/0123456789/admin')
    stub_request(:post, 'https://discord.com/api/webhooks/0123456789/mentor')
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
    travel_back
  end

  test 'user can training complete' do
    @user.discord_profile.times_id = '123456789000000011'
    @user.save!(validate: false)

    Discord::Server.stub(:delete_text_channel, true) do
      visit_with_auth new_training_completion_path, 'kensyu'
      find('label', text: 'とても良い').click
      fill_in 'user[opinion]', with: '研修終了の自由感想'
      page.accept_confirm '本当によろしいですか？' do
        click_on '研修を終了する'
      end
      assert_text '研修終了手続きが完了しました。'
    end
    @user.reload
    assert_equal Time.current, @user.training_completed_at
    assert_nil @user.discord_profile.times_id
    assert_nil @user.discord_profile.times_url
    assert_equal 'kensyuさんの研修が終了しました。', users(:komagata).notifications.last.message
    assert_equal 'kensyuさんの研修が終了しました。', users(:mentormentaro).notifications.last.message

    login_user 'kensyu', 'testtest'
    assert_text '研修終了したユーザーです'
  end

  test 'non-trainee user cannot access training completion page' do
    visit_with_auth new_training_completion_path, 'hajime'
    assert_text '研修生としてログインしてください'
  end

  test 'fails to send email when user completes training due to postmark error' do
    logs = []
    stub_warn_logger = ->(message) { logs << message }
    Rails.logger.stub(:warn, stub_warn_logger) do
      stub_postmark_error = ->(_user) { raise Postmark::InactiveRecipientError }
      UserMailer.stub(:training_complete, stub_postmark_error) do
        visit_with_auth new_training_completion_path, 'kensyu'
        find('label', text: 'とても良い').click
        page.accept_confirm '本当によろしいですか？' do
          click_on '研修を終了する'
        end
        assert_text '研修終了手続きが完了しました'
        assert_equal Time.current, @user.reload.training_completed_at
      end
    end

    assert_match '[Postmark] 受信者由来のエラーのためメールを送信できませんでした。：', logs.to_s
  end

  test 'does not show training completion to non mentors and non admins' do
    visit_with_auth "/users/#{users(:kensyuowata).id}", 'hatsuno'
    assert_no_text '研修終了情報（非公開）'
  end

  test 'mentors can see training completion info' do
    visit_with_auth "/users/#{users(:kensyuowata).id}", 'mentormentaro'
    assert_text '研修終了情報（非公開）'
  end

  test 'admins can see training completion info' do
    visit_with_auth "/users/#{users(:kensyuowata).id}", 'komagata'
    assert_text '研修終了情報（非公開）'
  end
end
