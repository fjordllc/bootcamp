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
    ordered_practices = Practice.category_order
    earlier = practices(:practice_23)
    middle = practices(:practice_20)
    later = practices(:practice_14)
    assert ordered_practices.index(earlier) < ordered_practices.index(middle)
    assert ordered_practices.index(middle) < ordered_practices.index(later)
  end
end
