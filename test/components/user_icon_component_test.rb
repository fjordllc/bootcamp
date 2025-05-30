# frozen_string_literal: true

require 'test_helper'

class UserIconComponentTest < ViewComponent::TestCase
  fixtures :users, :learning_time_frames

  test 'shows user icon if user has active learning time now' do
    travel_to Time.zone.local(2025, 5, 28, 12, 0, 0) do
      kimura = users(:kimura)
      LearningTimeFramesUser.create!(user: kimura, learning_time_frame_id: 85)

      users = User.students_and_trainees.joins(:learning_time_frames).merge(LearningTimeFrame.active_now)
      assert_includes users, kimura
    end
  end

  test 'does not show user icon if user does not have active learning time now' do
    travel_to Time.zone.local(2025, 5, 28, 14, 0, 0) do
      kimura = users(:kimura)
      LearningTimeFramesUser.create!(user: kimura, learning_time_frame_id: 85)

      users = User.students_and_trainees.joins(:learning_time_frames).merge(LearningTimeFrame.active_now)
      assert_not_includes users, kimura
    end
  end
end
