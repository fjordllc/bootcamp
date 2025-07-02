# frozen_string_literal: true

require 'application_system_test_case'

class Users::ActivityTimesTest < ApplicationSystemTestCase
  setup do
    kimura = users(:kimura)
    sunday_twenty_one = learning_time_frames(:sun21)
    monday_ten = learning_time_frames(:mon10)

    LearningTimeFramesUser.create!(user: kimura, learning_time_frame: sunday_twenty_one)
    LearningTimeFramesUser.create!(user: kimura, learning_time_frame: monday_ten)

    hatsuno = users(:hatsuno)
    tuesday_fifteen = learning_time_frames(:tue15)

    LearningTimeFramesUser.create!(user: hatsuno, learning_time_frame: tuesday_fifteen)
  end

  test 'show activity time page with users' do
    visit_with_auth '/users/activity_times?day_of_week=0&hour=21', 'kimura'

    assert_text 'Kimura Tadasi'
    assert_no_text 'Hatsuno Shinji'
  end

  test 'show users with current time as default' do
    travel_to Time.zone.local(2024, 1, 7, 21, 0, 0) do
      visit_with_auth '/users/activity_times', 'kimura'

      assert_text 'Kimura Tadasi'
      assert_no_text 'Hatsuno Shinji'
    end
  end
end
