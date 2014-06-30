require 'test_helper'

class PracticeTest < ActiveSupport::TestCase
  fixtures :learnings, :practices, :users

  test 'status(user)' do
    assert_equal \
      practices(:practice_1).status(users(:komagata)),
      :started

    assert_equal \
      practices(:practice_1).status(users(:machida)),
      :not_complete
  end

  test 'complete?(user)' do
    assert practices(:practice_1).complete?(users(:komagata))
    assert_not practices(:practice_1).complete?(users(:machida))
  end
end
