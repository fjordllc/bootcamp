# frozen_string_literal: true

require 'test_helper'

class DiscordAsyncAdapterTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    super
    @previous_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :test
  end

  def teardown
    ActiveJob::Base.queue_adapter = @previous_adapter
    super
  end

  test '#enqueue' do
    params = {
      kind: :graduated,
      body: 'test message',
      sender: users(:kimura),
      name: 'bob',
      webhook_url: Rails.application.config_for(:secrets)[:webhook][:admin]
    }

    assert_enqueued_jobs 1, only: DiscordJob do
      DiscordAsyncAdapter.new.enqueue(nil, params)
    end
  end
end
