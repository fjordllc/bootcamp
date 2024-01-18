# frozen_string_literal: true

require 'test_helper'

class HibernationTest < ActiveSupport::TestCase
  test '#calculate_absence_days' do
    user = users(:kyuukai)

    # kyuukaiの休会日は "2020-01-01 09:00:00"に設定されている。
    travel_to Time.zone.local(2020, 2, 1, 9, 0, 0) do
      assert_equal 31, Hibernation.new.calculate_absence_days(user)
    end
  end
end
