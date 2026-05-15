# frozen_string_literal: true

require 'test_helper'

class ActivityJobTest < ActiveJob::TestCase
  test '#perform' do
    params = {
      kind: :graduated,
      body: 'test message',
      sender: users(:kimura),
      receiver: users(:komagata),
      link: '/example',
      read: false
    }

    notification = ActivityJob.perform_now(params)

    assert notification
    assert_equal params[:kind].to_s, notification.kind
    assert_equal params[:body], notification.message
    assert_equal params[:sender], notification.sender
    assert_equal params[:receiver], notification.user
    assert_equal params[:link], notification.link
    assert_equal params[:read], notification.read
  end
end
