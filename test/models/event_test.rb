# frozen_string_literal: true

require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "should be valid" do
    assert events(:event_2).valid?
  end

  test "is_opening?" do
    event = events(:event_2)
    assert event.is_opening?
  end

  test "before_opening?" do
    event = events(:event_4)
    assert event.before_opening?
  end

  test "is_closing?" do
    event = events(:event_5)
    assert event.is_closing?
  end

  test "participants" do
    event = events(:event_2)
    participants = users(:hatsuno)
    assert_includes event.participants, participants
  end

  test "waitlist" do
    event = events(:event_3)
    waiting_user = users(:kimura)
    event.participations.create(user: waiting_user)
    assert_includes event.waitlist, waiting_user
  end

  test "should be invalid when start_at >= end_at" do
    event = events(:event_1)
    event.end_at = event.start_at - 1.hour
    assert event.invalid?
  end

  test "should be invalid when open_start_at >= open_end_at" do
    event = events(:event_1)
    event.open_end_at = event.open_start_at - 1.day
    assert event.invalid?
  end

  test "should be invalid when open_start_at >= start_at" do
    event = events(:event_1)
    event.open_start_at = event.start_at + 1.day
    assert event.invalid?
  end

  test "should be invalid when open_end_at > end_at" do
    event = events(:event_1)
    event.open_end_at = event.end_at + 1.day
    assert event.invalid?
  end
end
