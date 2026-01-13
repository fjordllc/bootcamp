# frozen_string_literal: true

require 'test_helper'
require 'supports/mock_env_helper'

class Scheduler::Daily::FetchExternalEntryTest < ActionDispatch::IntegrationTest
  include MockEnvHelper

  test 'token evaluation' do
    mock_env('TOKEN' => '') do
      get scheduler_daily_fetch_external_entry_path(token: '')
      assert_response :unauthorized
    end

    mock_env('TOKEN' => 'token') do
      get scheduler_daily_fetch_external_entry_path(token: 'invalid')
      assert_response :unauthorized

      ExternalEntry.stub(:fetch_and_save_rss_feeds, nil) do
        get scheduler_daily_fetch_external_entry_path(token: 'token')
        assert_response :ok
      end
    end
  end
end
