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
        Card.stub(:destroy_all, true) do
          mock_env('TOKEN' => 'token') do
            visit scheduler_daily_auto_retire_path(token: 'token')
          end
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

    admin_retirement_notification = admin.notifications.where(kind: Notification.kinds[:retired]).last
    mentor_retirement_notification = mentor.notifications.where(kind: Notification.kinds[:retired]).last

    assert_equal "😢 #{user.login_name}さんが退会しました。", admin_retirement_notification.message
    assert_equal "😢 #{user.login_name}さんが退会しました。", mentor_retirement_notification.message

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
        Card.stub(:destroy_all, true) do
          mock_env('TOKEN' => 'token') do
            visit scheduler_daily_auto_retire_path(token: 'token')
          end
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
end
