# frozen_string_literal: true

require 'test_helper'
require 'supports/mock_env_helper'

class Scheduler::Daily::AutoRetireTest < ActionDispatch::IntegrationTest
  include MockEnvHelper

  test 'token evaluation' do
    # サーバー側のTOKENが未設定
    mock_env('TOKEN' => '') do
      get scheduler_daily_auto_retire_path(token: '')
      assert_response 401
    end

    mock_env('TOKEN' => 'token') do
      # リクエストで指定したtokenが不正
      get scheduler_daily_auto_retire_path(token: 'invalid')
      assert_response 401

      # tokenが正しい
      Scheduler::Daily::AutoRetireController.stub_any_instance(:auto_retire) do
        get scheduler_daily_auto_retire_path(token: 'token')
        assert_response 200
      end
    end
  end
end
