# frozen_string_literal: true

require 'test_helper'

class TimelinesChannelTest < ActionCable::Channel::TestCase
  def setup
    @user = users(:hajime)
    @timeline = timelines(:timeline1)
    stub_connection current_user: @user
  end

  test 'transmit timelines when subscribed' do
    subscribe channel: 'timelines_channel'

    assert subscription.confirmed?
    assert_equal 'subscribe', transmissions.last['event']
  end

  test '#create_timeline' do
    subscribe channel: 'timelines_channel'

    assert_broadcasts('timelines_channel', 1) do
      perform :create_timeline, { timeline: { description: '今は勉強中です' } }
    end

    assert_broadcasts("user_#{@user.id}_timelines_channel", 1)
  end

  test '#update_timeline' do
    subscribe channel: 'timelines_channel'

    assert_broadcasts('timelines_channel', 1) do
      perform :update_timeline, { id: @timeline.id, timeline: { description: '今はミーティング中です' } }
    end

    assert_broadcasts("user_#{@user.id}_timelines_channel", 1)
  end

  test '#delete_timeline' do
    subscribe channel: 'timelines_channel'

    assert_broadcasts('timelines_channel', 1) do
      perform :delete_timeline, { id: @timeline.id }
    end

    assert_broadcasts("user_#{@user.id}_timelines_channel", 1)
  end

  test '#send_past_timelines' do
    subscribe channel: 'timelines_channel'

    perform :send_past_timelines, { id: @timeline.id }

    assert_equal 'send_past_timelines', transmissions.last['event']
  end
end
