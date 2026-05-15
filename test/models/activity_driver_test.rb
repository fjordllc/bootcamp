# frozen_string_literal: true

require 'test_helper'

class ActivityDriverTest < ActiveSupport::TestCase
  test '#call' do
    params = {
      kind: :graduated,
      body: 'test message',
      sender: users(:kimura),
      receiver: users(:komagata),
      link: '/example',
      read: false
    }

    driver = ActivityDriver.new
    notification = driver.call(params)

    assert notification
    assert_equal params[:kind].to_s, notification.kind
    assert_equal params[:body], notification.message
    assert_equal params[:sender], notification.sender
    assert_equal params[:receiver], notification.user
    assert_equal params[:link], notification.link
    assert_equal params[:read], notification.read
  end
end
