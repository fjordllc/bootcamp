# frozen_string_literal: true

require 'test_helper'

class UserIconListComponentTest < ViewComponent::TestCase
  fixtures :users, :learning_time_frames, :learning_time_frames_users

  test 'shows user icons if multiple users have active learning time now' do
    travel_to Time.zone.local(2025, 5, 28, 12, 0, 0) do
      users = User.students_and_trainees.joins(:learning_time_frames).merge(LearningTimeFrame.active_now)
      assert_includes users, users(:kimura)
      assert_includes users, users(:kensyu)
    end
  end

  # ログインユーザー自身は除外されることを確認するテスト
  test 'does not show login user icon even if login user have active learning time now' do
    travel_to Time.zone.local(2025, 5, 28, 12, 0, 0) do
      current_user = users(:hatsuno)
      users_for_time_slot = User.students_and_trainees
                                .joins(:learning_time_frames)
                                .merge(LearningTimeFrame.active_now)
                                .where.not(id: current_user.id)

      assert_includes users_for_time_slot, users(:kimura)
      assert_includes users_for_time_slot, users(:kensyu)
      assert_not_includes users_for_time_slot, current_user
    end
  end
end
