# frozen_string_literal: true

require 'test_helper'

class ActivityAsyncAdapterTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test '#enqueue' do
    params = {
      kind: :graduated,
      body: 'test message',
      sender: users(:kimura),
      receiver: users(:komagata),
      link: '/example',
      read: false
    }

    assert_enqueued_with(job: ActivityJob) do
      ActivityAsyncAdapter.new.enqueue(nil, params)
    end
  end
end
