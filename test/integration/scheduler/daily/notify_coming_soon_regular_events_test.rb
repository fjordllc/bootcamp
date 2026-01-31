# frozen_string_literal: true

require 'test_helper'
require 'supports/mock_env_helper'

class Scheduler::Daily::NotifyComingSoonRegularEventsTest < ActionDispatch::IntegrationTest
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
end
