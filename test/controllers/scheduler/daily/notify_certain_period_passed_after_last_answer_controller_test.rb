# frozen_string_literal: true

require 'test_helper'
require 'supports/mock_env_helper'

class Scheduler::Daily::NotifyCertainPeriodPassedAfterLastAnswerControllerTest < ActionDispatch::IntegrationTest
  include MockEnvHelper

  test 'missing or blank configured token is rejected' do
    [nil, '', ' '].each do |configured_token|
      mock_env('DB_NAME' => 'bootcamp_test', 'TOKEN' => configured_token) do
        Question.stub(:notify_certain_period_passed_after_last_answer, -> { flunk 'unauthorized request must not notify' }) do
          get scheduler_daily_notify_certain_period_passed_after_last_answer_path, params: { token: configured_token }
          assert_response :unauthorized
        end
      end
    end
  end

  test 'missing blank wrong and malformed request tokens are rejected' do
    mock_env('DB_NAME' => 'bootcamp_test', 'TOKEN' => 'token') do
      Question.stub(:notify_certain_period_passed_after_last_answer, -> { flunk 'unauthorized request must not notify' }) do
        [{}, { token: '' }, { token: ' ' }, { token: 'wrong' }, { token: 'invalid' },
         { token: ['token'] }, { token: { value: 'token' } }].each do |request_params|
          get scheduler_daily_notify_certain_period_passed_after_last_answer_path, params: request_params
          assert_response :unauthorized
        end
      end
    end
  end

  test 'matching configured token is accepted' do
    mock_env('DB_NAME' => 'bootcamp_test', 'TOKEN' => 'token') do
      Question.stub(:notify_certain_period_passed_after_last_answer, nil) do
        get scheduler_daily_notify_certain_period_passed_after_last_answer_path, params: { token: 'token' }
        assert_response :ok
      end
    end
  end
end
