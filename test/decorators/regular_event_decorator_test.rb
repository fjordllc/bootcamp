# frozen_string_literal: true

require 'test_helper'

class RegularEventDecoratorTest < ActiveSupport::TestCase
  include ActionView::TestCase::Behavior

  def setup
    ActiveDecorator::ViewContext.push(controller.view_context)
    @regular_event = ActiveDecorator::Decorator.instance.decorate(regular_events(:regular_event1))
    @finished_regular_event = ActiveDecorator::Decorator.instance.decorate(regular_events(:regular_event10))
  end

  test '#holding_cycles' do
    assert_equal '毎週日曜日', @regular_event.holding_cycles
  end

  test '#next_holding_date' do
    travel_to Time.zone.local(2022, 6, 1, 0, 0, 0) do
      assert_equal '次回の開催日は 2022年06月05日 です', @regular_event.next_holding_date
    end

    travel_to Time.zone.local(2022, 6, 5, 0, 0, 0) do
      assert_equal '本日開催', @regular_event.next_holding_date
    end

    travel_to Time.zone.local(2022, 6, 5, 15, 30, 0) do
      assert_equal '次回の開催日は 2022年06月12日 です', @regular_event.next_holding_date
    end

    travel_to Time.zone.local(2022, 6, 1, 0, 0, 0) do
      assert_equal '開催終了', @finished_regular_event.next_holding_date
    end
  end

  test '#upcoming_excluded_dates' do
    weekly_wed_event = ActiveDecorator::Decorator.instance.decorate(regular_events(:regular_event7))

    weekly_wed_event.regular_event_skip_dates.create!(
      skip_on: Date.new(2026, 4, 8),
      reason: '主催都合のため'
    )

    weekly_wed_event.regular_event_skip_dates.create!(
      skip_on: Date.new(2026, 5, 13),
      reason: '特別イベントのため'
    )

    weekly_wed_event.regular_event_skip_dates.create!(
      skip_on: Date.new(2026, 9, 30),
      reason: 'ミートアップのため'
    )

    skip_event_dates = weekly_wed_event.upcoming_excluded_dates(from: Date.new(2026, 4, 1), limit: 5)

    assert_equal [
      { date: Date.new(2026, 4, 8), reason: '主催都合のため' },
      { date: Date.new(2026, 4, 29), reason: '祝日(昭和の日)のため' },
      { date: Date.new(2026, 5, 6), reason: '祝日(振替休日)のため' },
      { date: Date.new(2026, 5, 13), reason: '特別イベントのため' },
      { date: Date.new(2026, 9, 23), reason: '祝日(秋分の日)のため' }
    ], skip_event_dates
  end

  test '#upcoming_excluded_dates ignores skip dates not matching repeat rules' do
    weekly_wed_event = ActiveDecorator::Decorator.instance.decorate(regular_events(:regular_event7))

    weekly_wed_event.regular_event_skip_dates.create!(
      skip_on: Date.new(2026, 4, 2),
      reason: '木曜日で登録したスキップ日'
    )

    skip_event_dates = weekly_wed_event.upcoming_excluded_dates(from: Date.new(2026, 4, 1), limit: 5)

    assert_not_includes skip_event_dates, {
      date: Date.new(2026, 4, 28),
      reason: '木曜日で登録したスキップ日'
    }
  end

  test '#upcoming_excluded_dates merges reasons when custom skip date and holiday is the same day' do
    weekly_wed_event = ActiveDecorator::Decorator.instance.decorate(regular_events(:regular_event7))

    weekly_wed_event.regular_event_skip_dates.create!(
      skip_on: Date.new(2026, 4, 29),
      reason: '主催都合のため'
    )

    skip_event_dates = weekly_wed_event.upcoming_excluded_dates(from: Date.new(2026, 4, 1), limit: 5)

    assert_includes skip_event_dates, {
      date: Date.new(2026, 4, 29),
      reason: '祝日(昭和の日)のため、主催都合のため'
    }
  end

  test '#upcoming_excluded_dates ignores blank reasons when merging with holiday' do
    weekly_wed_event = ActiveDecorator::Decorator.instance.decorate(regular_events(:regular_event7))

    weekly_wed_event.regular_event_skip_dates.create!(
      skip_on: Date.new(2026, 4, 29),
      reason: ''
    )

    skip_event_dates = weekly_wed_event.upcoming_excluded_dates(from: Date.new(2026, 4, 1), limit: 5)

    assert_includes skip_event_dates, {
      date: Date.new(2026, 4, 29),
      reason: '祝日(昭和の日)のため'
    }
  end

  test '#out_of_rule_skip_dates' do
    weekly_wed_event = ActiveDecorator::Decorator.instance.decorate(regular_events(:regular_event7))

    skip_date = weekly_wed_event.regular_event_skip_dates.create!(
      skip_on: Date.new(2026, 4, 28),
      reason: '火曜日で登録したスキップ日'
    )

    out_of_rule_skip_dates = weekly_wed_event.out_of_rule_skip_dates(from: Date.new(2026, 4, 1))

    assert_includes out_of_rule_skip_dates, skip_date
  end

  test '#out_of_rule_skip_dates is empty when all skip dates follow the repeat rules' do
    weekly_wed_event = ActiveDecorator::Decorator.instance.decorate(regular_events(:regular_event7))

    weekly_wed_event.regular_event_skip_dates.create!(
      skip_on: Date.new(2026, 4, 29), # 火曜日（水曜イベントに対してルール外）
      reason: '火曜日で登録したスキップ日'
    )

    out_of_rule_skip_dates = weekly_wed_event.out_of_rule_skip_dates(from: Date.new(2026, 4, 1))

    assert_empty out_of_rule_skip_dates
  end
end
