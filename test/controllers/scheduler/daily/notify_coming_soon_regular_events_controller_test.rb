# frozen_string_literal: true

require 'test_helper'
require 'supports/mock_env_helper'

class Scheduler::Daily::NotifyComingSoonRegularEventsControllerTest < ActionDispatch::IntegrationTest
  include MockEnvHelper

  test 'token evaluation' do
    mock_env('TOKEN' => '') do
      get scheduler_daily_notify_coming_soon_regular_events_path(token: '')
      assert_response :unauthorized
    end

    mock_env('TOKEN' => 'token') do
      get scheduler_daily_notify_coming_soon_regular_events_path(token: 'invalid')
      assert_response :unauthorized

      Scheduler::Daily::NotifyComingSoonRegularEventsController.stub_any_instance(:notify_coming_soon_regular_events) do
        get scheduler_daily_notify_coming_soon_regular_events_path(token: 'token')
        assert_response :ok
      end
    end
  end

  test 'notifies Discord of the regular events held today and tomorrow' do
    stub_message = stub_request(:post, 'https://discord.com/api/webhooks/0123456789/all')
                   .with(headers: { 'Content-Type' => 'application/json' }) do |request|
                     body = JSON.parse(request.body)
                     body['username'] == 'ピヨルド' &&
                       body['content'].include?('⚡️⚡️⚡️イベントのお知らせ⚡️⚡️⚡️') &&
                       body['content'].include?('< 今日 (05/05 金) 開催 >') &&
                       body['content'].include?('< 明日 (05/06 土) 開催 >') &&
                       body['content'].include?('Discord通知確認用イベント(土曜日午前8時から開催)') &&
                       body['content'].include?('Discord通知確認用イベント(土曜日 + 日曜日開催)') &&
                       body['content'].include?('Discord通知確認用イベント(土曜日開催)') &&
                       body['content'].include?('Discord通知確認用、祝日非開催イベント(金曜日 + 土曜日開催)') &&
                       body['content'].exclude?('Discord通知が来ないwipイベント(土曜日開催)')
    end
    delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal

    travel_to Time.zone.local(2023, 5, 5, 6, 0, 0) do
      mock_env('TOKEN' => 'token') do
        get scheduler_daily_notify_coming_soon_regular_events_path(token: 'token')
      end
    end

    assert_response :ok
    assert_requested(stub_message)
  ensure
    AbstractNotifier.delivery_mode = delivery_mode if delivery_mode
  end
end
