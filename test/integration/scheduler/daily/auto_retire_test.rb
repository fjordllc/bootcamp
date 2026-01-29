# frozen_string_literal: true

require 'test_helper'
require 'supports/mock_env_helper'

class Scheduler::Daily::AutoRetireTest < ActionDispatch::IntegrationTest
  include MockEnvHelper

  test 'token evaluation' do
    mock_env('TOKEN' => '') do
      get scheduler_daily_auto_retire_path(token: '')
      assert_response :unauthorized
    end

    mock_env('TOKEN' => 'token') do
      get scheduler_daily_auto_retire_path(token: 'invalid')
      assert_response :unauthorized

      Scheduler::Daily::AutoRetireController.stub_any_instance(:auto_retire) do
        get scheduler_daily_auto_retire_path(token: 'token')
        assert_response :ok
      end
    end
  end
end
