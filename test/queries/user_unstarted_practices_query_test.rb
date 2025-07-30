# frozen_string_literal: true

require 'test_helper'

class UserUnstartedPracticesQueryTest < ActiveSupport::TestCase
  test 'should return unstarted practices for given user' do
    user = users(:komagata)
    started_practice = practices(:practice1)
    completed_practice = practices(:practice2)
    submitted_practice = practices(:practice4)
    unstarted_practice = practices(:practice9)

    result = UserUnstartedPracticesQuery.new(user:).call

    assert_not_includes result, started_practice
    assert_not_includes result, completed_practice
    assert_not_includes result, submitted_practice
    assert_includes result, unstarted_practice
  end

  test 'should exclude practices with started status' do
    user = users(:komagata)
    started_practice = practices(:practice1)

    result = UserUnstartedPracticesQuery.new(user:).call

    assert_not_includes result, started_practice
  end

  test 'should exclude practices with submitted status' do
    user = users(:komagata)
    submitted_practice = practices(:practice4)

    result = UserUnstartedPracticesQuery.new(user:).call

    assert_not_includes result, submitted_practice
  end

  test 'should exclude practices with complete status' do
    user = users(:komagata)
    completed_practice = practices(:practice2)

    result = UserUnstartedPracticesQuery.new(user:).call

    assert_not_includes result, completed_practice
  end

  test 'should return different results for different users' do
    user1 = users(:komagata)
    user2 = users(:machida)

    result1 = UserUnstartedPracticesQuery.new(user: user1).call
    result2 = UserUnstartedPracticesQuery.new(user: user2).call

    assert_not_equal result1.to_a.sort, result2.to_a.sort
  end
end
