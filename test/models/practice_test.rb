require "test_helper"

class PracticeTest < ActiveSupport::TestCase
  fixtures :learnings, :practices, :users

  test "status(user)" do
    assert_equal \
      practices(:practice_1).status(users(:komagata)),
      :started

    assert_equal \
      practices(:practice_1).status(users(:machida)),
      :not_complete
  end

  test "has_task flag" do
    assert practices(:practice_3).has_task?
    assert practices(:practice_7).has_task?
    assert practices(:practice_11).has_task?
    assert_not practices(:practice_1).has_task?
    assert_not practices(:practice_12).has_task?
    assert_not practices(:practice_50).has_task?
  end

  test "exists_learning?(user)" do
    assert practices(:practice_1).exists_learning?(users(:komagata))
    assert_not practices(:practice_1).exists_learning?(users(:machida))
  end
end
