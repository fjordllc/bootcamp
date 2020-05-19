# frozen_string_literal: true

require "test_helper"

class TimelinesChannelTest < ActionCable::Channel::TestCase
  def setup
    @user = users(:hajime)
    @timeline = timelines(:timeline_1)
    stub_connection current_user: @user
  end

  test "transmit timelines when subscribed" do
    subscribe channel: "timelines_channel"

    assert subscription.confirmed?
    assert_equal "subscribe", transmissions.last["event"]
  end

  test "#create_timeline" do
    subscribe channel: "timelines_channel"

    assert_broadcasts("timelines_channel", 1) do
      perform :create_timeline,  { timeline: { description: "今は勉強中です" } }
    end
  end

  test "#update_timeline" do
    subscribe channel: "timelines_channel"

    assert_broadcasts("timelines_channel", 1) do
      perform :update_timeline, { id: @timeline.id,  timeline: { description: "今はミーティング中です" } }
    end
  end

  test "#delete_timeline" do
    subscribe channel: "timelines_channel"

    assert_broadcasts("timelines_channel", 1) do
      perform :delete_timeline,  { id: @timeline.id }
    end
  end
end
