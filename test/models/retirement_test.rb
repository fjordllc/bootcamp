# frozen_string_literal: true

require 'test_helper'

class RetirementTest < ActiveSupport::TestCase
  setup do
    @user = users(:hajime)
  end

  test 'execute calls all the necessary methods' do
    retirement = Retirement.by_self({}, user: @user)

    expected_methods = %i[
      assign_reason
      assign_date
      clear_hibernation_state
      save_user
      destroy_subscription
      clean_up_regular_events
      clear_github_info
      destroy_cards
      unmatch_pair_works
      publish
      notify
    ]

    called_methods = []
    expected_methods.each do |method|
      retirement.define_singleton_method(method) do
        called_methods << method
      end
    end

    retirement.execute

    assert_equal expected_methods, called_methods
  end

  test 'self retirement assigns retirement reason and notification type correctly' do
    retire_reason = '退会の理由'
    param = { satisfaction: 1, retire_reason: }

    retirement = Retirement.by_self(param, user: @user)
    strategy = retirement.instance_variable_get(:@strategy)

    retirement.execute

    assert_equal @user.retire_reason, retire_reason
    assert_equal strategy.notification_type, :retire
  end

  test 'self retirement completes and notifies after forbidden Discord deletion' do
    times_id = '987654321987654321'
    times_url = "https://discord.com/channels/1234567890123456789/#{times_id}"
    @user.discord_profile.update!(times_id:, times_url:)
    reports = []
    notifications = AbstractNotifier::Testing::Driver.enqueued_deliveries
    notification_count = notifications.count
    email_count = ActionMailer::Base.deliveries.count

    Rollbar.stub(:error, ->(*args) { reports << args }) do
      Discord::Server.stub(:authorize_token, 'Bot valid token') do
        VCR.use_cassette 'discord/server/delete_text_channel_with_missing_permissions' do
          assert Retirement.by_self({ satisfaction: 1, retire_reason: '退会の理由' }, user: @user).execute
        end
      end
    end

    assert_equal Date.current, @user.reload.retired_on
    assert_equal times_id, @user.discord_profile.reload.times_id
    assert_equal times_url, @user.discord_profile.times_url
    retirement_emails = ActionMailer::Base.deliveries.drop(email_count).select do |email|
      email.subject == '[FBC] 退会処理が完了しました' && email.to == [@user.email]
    end
    assert_equal 1, retirement_emails.size
    retirement_notifications = notifications.drop(notification_count)
    assert_equal User.admins_and_mentors.count, retirement_notifications.count
    assert_equal User.admins_and_mentors.ids.sort, retirement_notifications.map { |notification| notification[:receiver].id }.sort
    assert(retirement_notifications.all? { |notification| notification[:kind] == :retired && notification[:sender] == @user })
    assert_equal 1, reports.size
    error, context = reports.first
    assert_instance_of Discordrb::Errors::NoPermission, error
    assert_equal 'retirement.create', context[:event]
    assert_equal @user.id, context[:user_id]
    assert_equal times_id, context[:channel_id]
  end

  test 'auto retirement assigns retirement reason and notification type correctly' do
    retirement = Retirement.auto(user: @user)
    strategy = retirement.instance_variable_get(:@strategy)

    retirement.execute

    assert_equal @user.retire_reason, '（休会後三ヶ月経過したため自動退会）'
    assert_equal strategy.notification_type, :auto_retire
  end

  test 'admin retirement does not assign retirement reason or notification type' do
    retirement = Retirement.by_admin(user: @user)
    strategy = retirement.instance_variable_get(:@strategy)

    retirement.execute

    assert_nil @user.retire_reason
    assert_nil strategy.notification_type
  end

  test 'rolls back user update if save_user fails' do
    retirement = Retirement.by_self({}, user: @user)
    retirement.define_singleton_method(:save_user) do
      raise ActiveRecord::RecordInvalid.new, 'This is an exception'
    end

    retirement.execute
    @user.reload

    assert_nil @user.retired_on
  end

  test 'rolls back user update if Stripe update fails' do
    retirement = Retirement.by_self({}, user: @user)
    retirement.define_singleton_method(:destroy_subscription) do
      raise Stripe::StripeError.new, 'This is an exception'
    end

    retirement.execute
    @user.reload

    assert_nil @user.retired_on
  end
end
