# frozen_string_literal: true

require 'test_helper'

class DiscordAsyncAdapterTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test '#enqueue' do
    params = {
      kind: :graduated,
      body: 'test message',
      sender: users(:kimura),
      name: 'bob',
      webhook_url: Rails.application.secrets[:webhook][:admin]
    }

    assert_enqueued_with(job: DiscordJob) do
      DiscordAsyncAdapter.new.enqueue(nil, params)
    end
  end
end
