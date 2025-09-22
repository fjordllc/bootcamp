# frozen_string_literal: true

require 'test_helper'

class PairWorkHelperTest < ActionView::TestCase
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

  test 'disabled?' do
    past_date = Time.current.yesterday
    future_date = Time.current.tomorrow
    my_pair_work = pair_works(:pair_work1)

    assert disabled?(past_date)
    assert_not disabled?(future_date)
    assert disabled?(future_date, pair_work: my_pair_work)
  end

  test 'checked?' do
    future_date = Time.current.tomorrow
    past_date = Time.current.yesterday
    my_learning_time_frame_id = LearningTimeFramesUser.create!(user: current_user, learning_time_frame_id: 3).learning_time_frame_id

    assert checked?(future_date, my_learning_time_frame_id)
    assert_not checked?(past_date, my_learning_time_frame_id)
  end
end
