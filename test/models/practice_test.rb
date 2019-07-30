# frozen_string_literal: true

require "test_helper"

class PracticeTest < ActiveSupport::TestCase
  fixtures :learnings, :practices, :users

  test "status(user)" do
    assert_equal \
      practices(:practice_1).status(users(:komagata)),
      "started"

    assert_equal \
      practices(:practice_1).status(users(:machida)),
      "not_complete"
  end

  test "exists_learning?(user)" do
    assert practices(:practice_1).exists_learning?(users(:komagata))
    assert_not practices(:practice_1).exists_learning?(users(:machida))
  end

  test "category_order" do
    positions = Practice.category_order.pluck(:position)
    expected = [1, 3, 2, 4, 5, 6, 9, 10, 11, 12, 13, 23, 24, 25, 26, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 49, 50, 20, 21, 22, 7, 8, 28, 44, 45, 46, 47, 27, 48, 51, 16, 17, 19, 14, 15, 18, 52, 53, 54, 55, 56]
    assert_equal expected, positions
  end
end
