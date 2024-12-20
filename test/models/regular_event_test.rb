# frozen_string_literal: true

require 'test_helper'

class RegularEventTest < ActiveSupport::TestCase
  test '#organizers' do
    regular_event = regular_events(:regular_event1)
    organizers = users(:komagata)
    assert_includes regular_event.organizers, organizers
  end

  test 'is invalid when start_at >= end_at' do
    regular_event = regular_events(:regular_event1)
    regular_event.end_at = regular_event.start_at - 1.hour
    assert regular_event.invalid?
  end

  test 'titles formatted as markdown are invalid' do
    invalid_title = [
      '# 見出し1',
      '## 見出し2',
      '+ 順序なしリスト',
      '- 順序なしリスト',
      '* 順序なしリスト',
      '1. 順序付きリスト',
      '> 引用',
      '``` コードブロック',
      '~~取り消し線~~',
      '**強調**,',
      '__下線__',
      '||伏せ字||'
    ]

    regular_event = regular_events(:regular_event1)
    errors = invalid_title.filter_map do |title|
      regular_event.title = title
      title if regular_event.valid?
    end
    assert_empty errors
  end

  test '.scheduled_on(date)' do
    travel_to Time.zone.local(2017, 4, 3, 23, 0, 0) do
      today_date = Time.zone.today
      today_events_count = 3
      today_events = RegularEvent.scheduled_on(today_date)
      assert_equal today_events_count, today_events.count

      tomorrow_date = Time.zone.today + 1.day
      tomorrow_events_count = 1
      tomorrow_events = RegularEvent.scheduled_on(tomorrow_date)
      assert_equal tomorrow_events_count, tomorrow_events.count

      day_after_tomorrow_date = Time.zone.today + 2.days
      day_after_tomorrow_events_count = 3
      day_after_tomorrow_events = RegularEvent.scheduled_on(day_after_tomorrow_date)
      assert_equal day_after_tomorrow_events_count, day_after_tomorrow_events.count
    end
  end

  test 'schedulde_on?(date)' do
    travel_to Time.zone.local(2017, 4, 3, 23, 0, 0) do # Monday
      today_date = Time.zone.today
      monday_regular_event = regular_events(:regular_event26)
      assert monday_regular_event.scheduled_on?(today_date)

      tomorrow_date = Time.zone.today + 1.day
      tuesday_regular_event = regular_events(:regular_event27)
      assert tuesday_regular_event.scheduled_on?(tomorrow_date)

      day_after_tomorrow_date = Time.zone.today + 2.days
      wednesday_regular_event = regular_events(:regular_event7)
      assert wednesday_regular_event.scheduled_on?(day_after_tomorrow_date)
    end
  end

  test '#next_event_date' do
    regular_event = regular_events(:regular_event1)
    travel_to Time.zone.local(2022, 6, 1, 0, 0, 0) do
      assert_equal Date.new(2022, 6, 5), regular_event.next_event_date
    end
  end

  test '#cancel_participation' do
    regular_event = regular_events(:regular_event1)
    participant = regular_event_participations(:regular_event_participation1).user

    regular_event.cancel_participation(participant)
    assert_not regular_event.regular_event_participations.find_by(user_id: participant.id)
  end

  test '#watched_by?' do
    regular_event = regular_events(:regular_event1)
    user = users(:kimura)
    assert_not regular_event.watched_by?(user)

    watch = Watch.new(user:, watchable: regular_event)
    watch.save
    assert regular_event.watched_by?(user)
  end

  test '#participated_by?' do
    regular_event = regular_events(:regular_event1)
    user = users(:hatsuno)
    assert regular_event.participated_by?(user)

    user = users(:komagata)
    assert_not regular_event.participated_by?(user)
  end

  test '#assign_admin_as_organizer_if_none' do
    regular_event = RegularEvent.new(
      title: '主催者のいないイベント',
      description: '主催者のいないイベント',
      finished: false,
      hold_national_holiday: false,
      start_at: Time.zone.local(2020, 1, 1, 21, 0, 0),
      end_at: Time.zone.local(2020, 1, 1, 22, 0, 0),
      user: users(:kimura),
      category: 0,
      published_at: '2023-08-01 00:00:00'
    )
    regular_event.save(validate: false)
    regular_event.assign_admin_as_organizer_if_none
    assert_equal User.find_by(login_name: User::DEFAULT_REGULAR_EVENT_ORGANIZER), regular_event.organizers.first
  end

  test '#all_scheduled_dates' do
    start_date = Date.current
    end_date = Date.current.next_year
    wednesday_for_year = (start_date..end_date).select(&:wednesday?)

    regular_event = regular_events(:regular_event34)
    scheduled_dates = regular_event.all_scheduled_dates

    assert_equal wednesday_for_year, scheduled_dates
  end

  test '#format_event_date' do
    travel_to Time.zone.local(2024, 8, 5, 23, 0, 0) do
      regular_event = regular_events(:regular_event34)
      event_date = Date.new(2024, 8, 7)
      transformed_regular_event = regular_event.transform_for_subscription(event_date)
      assert_equal DateTime.new(2024, 8, 7, 21, 0, 0, '+09:00'), transformed_regular_event.start_on
      assert_equal DateTime.new(2024, 8, 7, 22, 0, 0, '+09:00'), transformed_regular_event.end_on
    end
  end

  test '.fetch_participated_regular_events' do
    travel_to Time.zone.local(2024, 8, 5, 23, 0, 0) do
      user = users(:kimura)

      participated_regular_events = RegularEvent.fetch_participated_regular_events(user)
      assert_equal 157, participated_regular_events.count
    end
  end
end
