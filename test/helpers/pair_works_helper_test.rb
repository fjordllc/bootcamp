# frozen_string_literal: true

require 'test_helper'

class PairWorksHelperTest < ActionView::TestCase
  setup do
    def current_user
      users(:kimura)
    end
  end

  test 'schedule_dates' do
    created_at = Time.zone.local(2025, 1, 1, 0, 0, 0)
    dates = [
      Date.new(2025, 1, 1),
      Date.new(2025, 1, 2),
      Date.new(2025, 1, 3),
      Date.new(2025, 1, 4),
      Date.new(2025, 1, 5),
      Date.new(2025, 1, 6),
      Date.new(2025, 1, 7)
    ]
    assert_equal dates, schedule_dates(created_at)

    date = Date.new(2025, 1, 1)
    assert_equal dates, schedule_dates(date)
  end

  test 'sorted_wdays' do
    wdays_if_wednesday = [3, 4, 5, 6, 0, 1, 2]
    assert_equal wdays_if_wednesday, sorted_wdays(Date.new(2025, 1, 1))
  end

  test 'schedule_check_disabled?' do
    past_date = Time.current.yesterday
    future_date = Time.current.tomorrow
    my_pair_work = pair_works(:pair_work1)

    assert schedule_check_disabled?(past_date)
    assert_not schedule_check_disabled?(future_date)
    assert schedule_check_disabled?(future_date, pair_work: my_pair_work)
  end

  test 'learning_time_frame_checked?' do
    future_date = Time.current.tomorrow
    past_date = Time.current.yesterday
    my_learning_time_frame_id = LearningTimeFramesUser.create!(user: current_user, learning_time_frame_id: 3).learning_time_frame_id

    assert learning_time_frame_checked?(future_date, my_learning_time_frame_id)
    assert_not learning_time_frame_checked?(past_date, my_learning_time_frame_id)
  end
  test 'schedule_target_time' do
    elapsed_day_count = 1
    elapsed_time_count = 1
    now = Time.current.beginning_of_day
    target_time = now + elapsed_day_count.days + elapsed_time_count.hours

    assert_equal target_time, schedule_target_time(elapsed_day_count, elapsed_time_count)
  end

  test 'schedule_check_box_id' do
    travel_to Time.zone.local(2025, 1, 1, 0, 0, 0) do
      elapsed_day_count = 1
      elapsed_time_count = 1
      target_time = schedule_target_time(elapsed_day_count, elapsed_time_count)

      assert_equal 'schedule_ids_202501020100', schedule_check_box_id(target_time)
    end
  end
end
