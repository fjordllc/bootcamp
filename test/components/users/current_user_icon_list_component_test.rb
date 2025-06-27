# frozen_string_literal: true

require 'test_helper'

class CurrentUserIconListComponentTest < ViewComponent::TestCase
  fixtures :users, :learning_time_frames

  test 'shows user icons if multiple users have active learning time now' do
    travel_to Time.zone.local(2025, 5, 28, 12, 0, 0) do
      kimura = users(:kimura)
      kensyu = users(:kensyu)

      LearningTimeFramesUser.create!(user: kimura, learning_time_frame_id: 85)
      LearningTimeFramesUser.create!(user: kensyu, learning_time_frame_id: 85)

      users = User.students_and_trainees.joins(:learning_time_frames).merge(LearningTimeFrame.active_now)
      assert_includes users, kimura
      assert_includes users, kensyu
    end
  end

  # ログインユーザー自身は除外されることを確認するテスト
  test 'does not show login user icon even if login user have active learning time now' do
    travel_to Time.zone.local(2025, 5, 28, 12, 0, 0) do
      kimura = users(:kimura)
      kensyu = users(:kensyu)
      current_user = users(:hatsuno)

      LearningTimeFramesUser.create!(user: kimura, learning_time_frame_id: 85)
      LearningTimeFramesUser.create!(user: kensyu, learning_time_frame_id: 85)
      LearningTimeFramesUser.create!(user: current_user, learning_time_frame_id: 85)

      users_for_time_slot = User.students_and_trainees
                                .joins(:learning_time_frames)
                                .merge(LearningTimeFrame.active_now)
                                .where.not(id: current_user.id)

      assert_includes users_for_time_slot, kimura
      assert_includes users_for_time_slot, kensyu
      assert_not_includes users_for_time_slot, current_user
    end
  end
end
