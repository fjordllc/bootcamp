# frozen_string_literal: true

require 'test_helper'
require 'supports/mock_env_helper'

class Scheduler::Daily::NotifyCertainPeriodPassedAfterLastAnswerTest < ActionDispatch::IntegrationTest
  include MockEnvHelper

  test 'token evaluation' do
    mock_env('TOKEN' => '') do
      get scheduler_daily_notify_certain_period_passed_after_last_answer_path(token: '')
      assert_response 401
    end

    mock_env('TOKEN' => 'token') do
      get scheduler_daily_notify_certain_period_passed_after_last_answer_path(token: 'invalid')
      assert_response 401

      Question.stub(:notify_certain_period_passed_after_last_answer, nil) do
        get scheduler_daily_notify_certain_period_passed_after_last_answer_path(token: 'token')
        assert_response 200
      end
    end
  end
end
