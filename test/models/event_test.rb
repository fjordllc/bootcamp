# frozen_string_literal: true

require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "should be valid" do
    assert events(:event_2).valid?
  end

  test "opening?" do
    event = events(:event_2)
    assert event.opening?
  end

  test "before_opening?" do
    event = events(:event_4)
    assert event.before_opening?
  end

  test "closing?" do
    event = events(:event_5)
    assert event.closing?
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

  test "can_participate?" do
    event = events(:event_3)
    assert_equal false, event.can_participate?
  end

  test "don't move up when waiting user canceled" do
    event = events(:event_3)
    waiting_participation = participations(:participation_2)

    event.cancel_participation!(event: event, user: waiting_participation.user)

    assert_includes event.participations.disabled, participations(:participation_4)
  end

  test "waiting user move up when participant cancel" do
    event = events(:event_3)
    participant = participations(:participation_3).user
    first_waiting_participation = participations(:participation_2)

    event.cancel_participation!(event: event, user: participant)

    assert_not_includes event.participations.disabled, first_waiting_participation
  end

  test "don't move up when there is not waiting user" do
    event = events(:event_2)
    participant_1 = participations(:participation_1)
    participant_2 = participations(:participation_5)

    event.cancel_participation!(event: event, user: participant_1.user)

    assert_equal [participant_2], event.participations
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
