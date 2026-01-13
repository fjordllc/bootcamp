# frozen_string_literal: true

require 'test_helper'
require 'supports/mock_env_helper'

class Scheduler::Daily::NotifyCertainPeriodPassedAfterLastAnswerTest < ActionDispatch::IntegrationTest
  include MockEnvHelper

  test 'token evaluation' do
    mock_env('TOKEN' => '') do
      get scheduler_daily_notify_certain_period_passed_after_last_answer_path(token: '')
      assert_response :unauthorized
    end

    mock_env('TOKEN' => 'token') do
      get scheduler_daily_notify_certain_period_passed_after_last_answer_path(token: 'invalid')
      assert_response :unauthorized

      Question.stub(:notify_certain_period_passed_after_last_answer, nil) do
        get scheduler_daily_notify_certain_period_passed_after_last_answer_path(token: 'token')
        assert_response :ok
      end
    end
  end
end
