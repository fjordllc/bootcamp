# frozen_string_literal: true

require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "#opening?" do
    event = events(:event_2)
    assert event.opening?
  end

  test "#before_opening?" do
    event = events(:event_4)
    assert event.before_opening?
  end

  test "#closing?" do
    event = events(:event_5)
    assert event.closing?
  end

  test "#participants" do
    event = events(:event_2)
    participants = users(:hatsuno)
    assert_includes event.participants, participants
  end

  test "#waitlist" do
    event = events(:event_3)
    waiting_user = users(:kimura)
    event.participations.create(user: waiting_user)
    assert_includes event.waitlist, waiting_user
  end

  test "#can_participate?" do
    event = events(:event_3)
    assert_not event.can_participate?
  end

  test "#cancel_participation" do
    event = events(:event_3)
    participant = participations(:participation_3).user
    waiting_participation = participations(:participation_2)
    move_up_participation = participations(:participation_4)

    event.cancel_participation!(waiting_participation.user)
    assert_includes event.participations.disabled, move_up_participation

    event.cancel_participation!(participant)
    assert_not_includes event.participations.disabled, move_up_participation
  end

  test "#update_participations" do
    event = events(:event_3)
    move_up_participation = participations(:participation_2)

    event.update(capacity: 2)
    event.update_participations

    assert_not_includes event.participations.disabled, move_up_participation
  end

  test "#send_notification" do
    event = events(:event_3)
    user = users(:hatsuno)
    event.send_notification(user)
    assert Notification.where(user: user, path: "/events/#{event.id}").exists?
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
