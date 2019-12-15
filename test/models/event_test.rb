# frozen_string_literal: true

require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "should be valid" do
    assert events(:event_2).valid?
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
