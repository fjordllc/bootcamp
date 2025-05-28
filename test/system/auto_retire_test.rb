# frozen_string_literal: true

require 'application_system_test_case'

class AutoRetireTest < ApplicationSystemTestCase
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test 'retire after three-month hibernation' do
    user = users(:kyuukai)
    travel_to Time.zone.local(2020, 4, 2, 0, 0, 0) do
      VCR.use_cassette 'subscription/update' do
        mock_env('TOKEN' => 'token') do
          visit scheduler_daily_auto_retire_path(token: 'token')
        end
      end
      assert_equal Date.current, user.reload.retired_on
    end

    assert_equal '（休会後三ヶ月経過したため自動退会）', user.retire_reason
    assert_nil user.hibernated_at
    login_user 'kyuukai', 'testtest'
    assert_text '退会したユーザーです'

    assert_requested(:post, "https://api.stripe.com/v1/subscriptions/#{user.subscription_id}") do |req|
      req.body.include?('cancel_at_period_end=true')
    end

    admin = users(:komagata)
    mentor = users(:mentormentaro)

    assert_equal "😢 #{user.login_name}さんが退会しました。", admin.notifications.last.message
    assert_equal "😢 #{user.login_name}さんが退会しました。", mentor.notifications.last.message

    mails = ActionMailer::Base.deliveries
    mail_to_admin = mails.find { |m| m.to == [admin.email] }
    assert_equal "[FBC] #{user.login_name}さんが退会しました。", mail_to_admin.subject
    mail_to_mentor = mails.find { |m| m.to == [mentor.email] }
    assert_equal "[FBC] #{user.login_name}さんが退会しました。", mail_to_mentor.subject
    mail_to_user = mails.find { |m| m.to == [user.email] }
    assert_equal '[FBC] 重要なお知らせ：受講ステータスの変更について', mail_to_user.subject
  end

  test 'not retire when hibernated for less than three months' do
    user = users(:kyuukai)
    travel_to Time.zone.local(2020, 4, 1, 0, 0, 0) do
      VCR.use_cassette 'subscription/update' do
        mock_env('TOKEN' => 'token') do
          visit scheduler_daily_auto_retire_path(token: 'token')
        end
      end
      assert_nil user.reload.retired_on
    end
  end

  test 'not retire when not_auto_retire is true' do
    user = users(:kyuukai)

    visit_with_auth edit_admin_user_path(user), 'komagata'
    check '休会三ヶ月後に自動退会しない', allow_label_click: true
    click_on '更新する'
    logout

    travel_to Time.zone.local(2020, 4, 2, 0, 0, 0) do
      mock_env('TOKEN' => 'token') do
        visit scheduler_daily_auto_retire_path(token: 'token')
      end
      assert_nil user.reload.retired_on
    end
  end

  test 'do nothing with already retired user' do
    user = users(:kyuukai)

    retired_date = Date.new(2020, 4, 1)
    user.update!(retired_on: retired_date)

    travel_to Time.zone.local(2020, 4, 2, 0, 0, 0) do
      mock_env('TOKEN' => 'token') do
        visit scheduler_daily_auto_retire_path(token: 'token')
      end
      assert_equal retired_date, user.reload.retired_on
    end
  end

  test 'delete unfinished data when retire' do
    user = users(:kyuukai)
    user.update!(career_path: 1)
    assert user.products.unchecked.count.positive?
    assert user.reports.wip.count.positive?

    travel_to Time.zone.local(2020, 4, 2, 0, 0, 0) do
      VCR.use_cassette 'subscription/update' do
        mock_env('TOKEN' => 'token') do
          visit scheduler_daily_auto_retire_path(token: 'token')
        end
      end
      assert_equal Date.current, user.reload.retired_on
    end

    assert_not_equal user.career_path, 1
    assert_equal 0, user.products.unchecked.count
    assert_equal 0, user.reports.wip.count
  end

  test 'delete times channel when retire' do
    user = users(:kyuukai)
    user.discord_profile.times_id = '987654321987654321'
    user.discord_profile.account_name = 'kyuukai#1234'
    user.discord_profile.save!(validate: false)

    travel_to Time.zone.local(2020, 4, 2, 0, 0, 0) do
      Discord::Server.stub(:delete_text_channel, true) do
        VCR.use_cassette 'subscription/update' do
          mock_env('TOKEN' => 'token') do
            visit scheduler_daily_auto_retire_path(token: 'token')
          end
        end
      end
      assert_equal Date.current, user.reload.retired_on
    end
    assert_nil user.discord_profile.times_id
  end

  test 'retire with postmark error' do
    user = users(:kyuukai)
    logs = []
    stub_warn_logger = ->(message) { logs << message }
    Rails.logger.stub(:warn, stub_warn_logger) do
      stub_postmark_error = ->(_user) { raise Postmark::InactiveRecipientError }
      UserMailer.stub(:auto_retire, stub_postmark_error) do
        travel_to Time.zone.local(2020, 4, 2, 0, 0, 0) do
          VCR.use_cassette 'subscription/update' do
            mock_env('TOKEN' => 'token') do
              visit scheduler_daily_auto_retire_path(token: 'token')
            end
          end
          assert_equal Date.current, user.reload.retired_on
        end
      end
    end
    assert_match '[Postmark] 受信者由来のエラーのためメールを送信できませんでした。：', logs.to_s
  end

  test 'retire with invalid user status' do
    user = users(:kyuukai)
    user.twitter_account = '不正なツイッターアカウント名'
    user.save!(validate: false)
    assert user.invalid?

    travel_to Time.zone.local(2020, 4, 2, 0, 0, 0) do
      VCR.use_cassette 'subscription/update' do
        mock_env('TOKEN' => 'token') do
          visit scheduler_daily_auto_retire_path(token: 'token')
        end
      end
      assert_equal Date.current, user.reload.retired_on
    end
  end

  test 'send mail one week before auto retire' do
    travel_to Time.zone.local(2020, 3, 26, 0, 0, 0) do
      mock_env('TOKEN' => 'token') do
        visit scheduler_daily_send_mail_to_hibernation_user_path(token: 'token')
      end
    end

    user = users(:kyuukai)
    mails = ActionMailer::Base.deliveries
    mail_to_user = mails.find { |m| m.to == [user.email] }
    assert_equal '[FBC] ご注意：休会期限の接近について', mail_to_user.subject
  end
end
