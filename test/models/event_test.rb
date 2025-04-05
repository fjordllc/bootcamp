# frozen_string_literal: true

require 'test_helper'

class EventTest < ActiveSupport::TestCase
  test '.scheduled_on(date)' do
    travel_to Time.zone.local(2017, 4, 3, 8, 0, 0) do
      today_date = Time.zone.today
      today_events_count = 2
      today_events = Event.scheduled_on(today_date)
      assert_equal today_events_count, today_events.count

      tomorrow_date = Time.zone.today + 1.day
      tomorrow_events_count = 1
      tomorrow_events = Event.scheduled_on(tomorrow_date)
      assert_equal tomorrow_events_count, tomorrow_events.count

      day_after_tomorrow_date = Time.zone.today + 2.days
      day_after_tomorrow_events_count = 1
      day_after_tomorrow_events = Event.scheduled_on(day_after_tomorrow_date)
      assert_equal day_after_tomorrow_events_count, day_after_tomorrow_events.count
    end
  end

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
    assert Notification.where(user:, sender: event.user, link: "/events/#{event.id}").exists?
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

  test '.can_move_up_the_waitlist?' do
    event = events(:event3)
    event.update(capacity: 10)
    assert event.can_move_up_the_waitlist?
  end

  test '.fetch_participated_ids' do
    user = users(:kimura)

    ids = Event.fetch_participated_ids(user)
    assert 200_404_551, ids
    assert 318_291_967, ids
  end

  test '.fetch_upcoming_ids' do
    ids = Event.fetch_upcoming_ids
    assert 308_029_005, ids
    assert 626_726_618, ids
    assert 994_018_171, ids
    assert 205_042_674, ids
  end

  test '.scheduled_on_without_ended' do
    travel_to Time.zone.local(2024, 12, 1, 10, 0, 0) do
      today_date = Time.zone.today
      events = Event.scheduled_on_without_ended(today_date)
      event_in_progress = events(:event35)
      event_ended = events(:event36)
      assert_includes events, event_in_progress
      assert_not_includes events, event_ended
    end
  end
end
