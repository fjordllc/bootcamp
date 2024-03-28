# frozen_string_literal: true

require 'test_helper'

class UpcomingEventDecoratorTest < ActiveSupport::TestCase
  def setup
    @special_event = ActiveDecorator::Decorator.instance.decorate(events(:event1))
    @regular_mtg = ActiveDecorator::Decorator.instance.decorate(regular_events(:regular_event1))
    @regular_reading = ActiveDecorator::Decorator.instance.decorate(regular_events(:regular_event4))
    @national_holiday = Time.zone.parse('2023-1-1')
    # 金・土・日のどれか
    @non_national_holiday = [Time.zone.parse('2023-9-8'), Time.zone.parse('2023-9-9'), Time.zone.parse('2023-9-10')].sample
  end

  test '#holding? on non national holiday always be true' do
    assert @special_event.holding?(@non_national_holiday)
    assert @regular_mtg.holding?(@non_national_holiday)
    assert @regular_reading.holding?(@non_national_holiday)
  end

  test 'special event #holding? always be true' do
    assert @special_event.holding?(@national_holiday)
    assert @special_event.holding?(@non_national_holiday)
  end

  test 'regular event #holding? depends on the rule' do
    assert_not @regular_mtg.holding?(@national_holiday)
    assert @regular_reading.holding?(@non_national_holiday)
  end

  test '#label_style' do
    style_table = {
      @special_event => 'is-special',
      @regular_mtg => 'is-meeting',
      @regular_reading => 'is-reading_circle'
    }

    style_table.each do |event, expected_style|
      assert_equal expected_style, event.label_style
    end
  end

  test '#inner_title_style' do
    assert_equal 'card-list-item__label-inner.is-sm', @special_event.inner_title_style

    [@regular_mtg, @regular_reading].each do |regular_event|
      assert_nil regular_event.inner_title_style
    end
  end

  test '#inner_title' do
    assert_equal '特別<br>イベント', @special_event.inner_title
    assert_equal 'MTG', @regular_mtg.inner_title
    assert_equal '輪読会', @regular_reading.inner_title
  end

  test '#translated_holding_date' do
    travel_to Time.zone.local(2019, 12, 20, 0, 0, 0) do
      assert_equal '2019年12月20日(金) 19:00', @special_event.translated_holding_date(Time.zone.today)
    end

    travel_to Time.zone.local(2020, 1, 1, 0, 0, 0) do
      assert_equal '2020年01月01日(水) 15:00', @regular_mtg.translated_holding_date(Time.zone.today)
    end
  end
end
