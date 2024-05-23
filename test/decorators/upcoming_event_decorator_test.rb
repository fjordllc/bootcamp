# frozen_string_literal: true

require 'test_helper'
require 'active_decorator_test_case'

class UpcomingEventDecoratorTest < ActiveDecoratorTestCase
  setup do
    special = events(:event1)
    regular_mtg = regular_events(:regular_event1)
    regular_reading = regular_events(:regular_event4)

    scheduled_date = Time.zone.today # Decoratorなので日付はいつでもOK
    upcoming_special = UpcomingEvent.new(special, scheduled_date)
    upcoming_regular_mtg = UpcomingEvent.new(regular_mtg, scheduled_date)
    upcoming_regular_reading = UpcomingEvent.new(regular_reading, scheduled_date)

    @decorated_upcoming_special = decorate(upcoming_special)
    @decorated_upcoming_mtg = decorate(upcoming_regular_mtg)
    @decorated_upcoming_reading = decorate(upcoming_regular_reading)
  end

  test '#label_style?' do
    assert_equal 'is-special', @decorated_upcoming_special.label_style
    assert_equal 'is-meeting', @decorated_upcoming_mtg.label_style
    assert_equal 'is-reading_circle', @decorated_upcoming_reading.label_style
  end

  test '#inner_title_style?' do
    assert_equal 'card-list-item__label-inner.is-sm', @decorated_upcoming_special.inner_title_style
    assert_nil @decorated_upcoming_mtg.inner_title_style
    assert_nil @decorated_upcoming_reading.inner_title_style
  end

  test '#inner_title' do
    assert_equal '特別<br>イベント', @decorated_upcoming_special.inner_title
    assert_equal 'MTG', @decorated_upcoming_mtg.inner_title
    assert_equal '輪読会', @decorated_upcoming_reading.inner_title
  end
end
