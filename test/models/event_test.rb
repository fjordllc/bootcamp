# frozen_string_literal: true

require 'test_helper'

class EventTest < ActiveSupport::TestCase
  test '#opening?' do
    event = events(:event2)
    assert event.opening?
  end

  test '#before_opening?' do
    event = events(:event4)
    assert event.before_opening?
  end

  test '#closing?' do
    event = events(:event5)
    assert event.closing?
  end

  test '#ended?' do
    event = events(:event6)
    assert event.ended?
  end

  test '#participants' do
    event = events(:event2)
    participants = users(:hatsuno)
    assert_includes event.participants, participants
  end

  test '#waitlist' do
    event = events(:event3)
    waiting_user = users(:kimura)
    event.participations.create(user: waiting_user)
    assert_includes event.waitlist, waiting_user
  end

  test '#participants_count' do
    waited_event = events(:event3)
    assert_equal waited_event.participants_count, 1
    not_waited_event = events(:event2)
    assert_equal not_waited_event.participants_count, 2
  end

  test '#waitlist_count' do
    waited_event = events(:event3)
    assert_equal waited_event.waitlist_count, 2
    not_waited_event = events(:event2)
    assert_equal not_waited_event.waitlist_count, 0
  end

  test '#can_participate?' do
    event = events(:event3)
    assert_not event.can_participate?
  end

  test '#cancel_participation' do
    event = events(:event3)
    participant = participations(:participation3).user
    waiting_participation = participations(:participation2)
    move_up_participation = participations(:participation4)

    event.cancel_participation!(waiting_participation.user)
    assert_includes event.participations.disabled, move_up_participation

    event.cancel_participation!(participant)
    assert_not_includes event.participations.disabled, move_up_participation
  end

  test '#update_participations' do
    event = events(:event3)
    move_up_participation = participations(:participation2)

    event.update(capacity: 2)
    event.update_participations

    assert_not_includes event.participations.disabled, move_up_participation
  end

  test '#send_notification' do
    event = events(:event3)
    user = users(:hatsuno)
    event.send_notification(user)
    assert Notification.where(user: user, path: "/events/#{event.id}").exists?
  end

  test 'should be invalid when start_at >= end_at' do
    event = events(:event1)
    event.end_at = event.start_at - 1.hour
    assert event.invalid?
  end

  test 'should be invalid when open_start_at >= open_end_at' do
    event = events(:event1)
    event.open_end_at = event.open_start_at - 1.day
    assert event.invalid?
  end

  test 'should be invalid when open_start_at >= start_at' do
    event = events(:event1)
    event.open_start_at = event.start_at + 1.day
    assert event.invalid?
  end

  test 'should be invalid when open_end_at > end_at' do
    event = events(:event1)
    event.open_end_at = event.end_at + 1.day
    assert event.invalid?
  end
end
