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
      today_events_count = 4
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

  test '#participated_by?' do
    regular_event = regular_events(:regular_event1)
    user = users(:hatsuno)
    assert regular_event.participated_by?(user)

    user = users(:komagata)
    assert_not regular_event.participated_by?(user)
  end

  test '#close_or_destroy_organizer closes the event when only one organizer exists' do
    user = users(:kimura)
    regular_event = regular_events(:regular_event5) # kimuraが1人で主催しているイベント

    assert_no_difference -> { regular_event.regular_event_organizers.count },
                         -> { regular_event.regular_event_organizers.where(user: user).count } do
      assert_changes -> { regular_event.finished }, from: false, to: true do
        regular_event.close_or_destroy_organizer(user)
      end
    end
  end

  test '#close_or_destroy_organizer removes the organizer when multiple organizers exist' do
    user = users(:kimura)
    regular_event = regular_events(:regular_event5) # kimuraが1人で主催しているイベント
    regular_event.regular_event_organizers.create!(user: users(:hatsuno))

    assert_difference -> { regular_event.regular_event_organizers.count } => -1,
                      -> { regular_event.regular_event_organizers.where(user: user).count } => -1 do
      assert_no_changes -> { regular_event.finished } do
        regular_event.close_or_destroy_organizer(user)
      end
    end
  end

  test '#all_scheduled_dates' do
    start_date = Date.current
    end_date = Date.current.next_year
    wednesday_for_year = (start_date..end_date).select(&:wednesday?)

    regular_event = regular_events(:regular_event34)
    scheduled_dates = regular_event.all_scheduled_dates

    assert_equal wednesday_for_year, scheduled_dates
  end

  test '#all_scheduled_dates return odd or even week dates if event held on odd or even week' do
    all_dates_for_year = (Date.current..Date.current.next_year)

    regular_event_held_on_odd_week_thursdays = regular_events(:regular_event40)
    odd_week_thursdays_for_year = all_dates_for_year.select { |date| date.cweek.odd? && date.thursday? }
    assert_equal odd_week_thursdays_for_year, regular_event_held_on_odd_week_thursdays.all_scheduled_dates

    regular_event_held_on_even_week_thursdays = regular_events(:regular_event41)
    even_week_thursdays_for_year = all_dates_for_year.select { |date| date.cweek.even? && date.thursday? }
    assert_equal even_week_thursdays_for_year, regular_event_held_on_even_week_thursdays.all_scheduled_dates
  end

  test '#transform_for_subscription' do
    travel_to Time.zone.local(2024, 8, 5, 23, 0, 0) do
      regular_event = RegularEvent.new(start_at: '21:00', end_at: '22:00')
      event_date = Date.new(2024, 8, 7)
      transformed_regular_event = regular_event.transform_for_subscription(event_date)

      assert_equal Time.zone.parse('2024-08-07 21:00'), transformed_regular_event.start_on
      assert_equal Time.zone.parse('2024-08-07 22:00'), transformed_regular_event.end_on
      assert_equal 'JST', transformed_regular_event.start_on.zone, 'タイムゾーンが日本標準時(Japan Standard Time)と異なります'
    end
  end

  test '.fetch_participated_regular_events' do
    travel_to Time.zone.local(2024, 8, 5, 23, 0, 0) do
      user = users(:kimura)

      participated_regular_events = RegularEvent.fetch_participated_regular_events(user)
      assert_equal 157, participated_regular_events.count
    end
  end

  test '.scheduled_on_without_ended' do
    travel_to Time.zone.local(2024, 12, 1, 10, 0, 0) do
      today_date = Time.zone.today
      regular_events = RegularEvent.scheduled_on_without_ended(today_date)
      regular_event_in_progress = regular_events(:regular_event36)
      regular_event_ended = regular_events(:regular_event37)
      assert_includes regular_events, regular_event_in_progress
      assert_not_includes regular_events, regular_event_ended
    end
  end

  test '.scheduled_on_without_ended in tomorrow’s event' do
    travel_to Time.zone.local(2024, 12, 1, 10, 0, 0) do
      tomorrow = Time.zone.tomorrow
      regular_events = RegularEvent.scheduled_on_without_ended(tomorrow)
      regular_event_scheduled_for_tomorrow = regular_events(:regular_event38)
      assert_includes regular_events, regular_event_scheduled_for_tomorrow
    end
  end
end
