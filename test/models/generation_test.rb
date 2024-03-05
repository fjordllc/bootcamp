# frozen_string_literal: true

require 'test_helper'

class GenerationTest < ActiveSupport::TestCase
  test '#start_date' do
    assert_equal Time.zone.local(2013, 1, 1), Generation.new(1).start_date
    assert_equal Time.zone.local(2013, 4, 1), Generation.new(2).start_date
  end

  test '#end_date' do
    assert_equal Time.zone.local(2013, 3, 31).end_of_day, Generation.new(1).end_date
    assert_equal Time.zone.local(2013, 6, 30).end_of_day, Generation.new(2).end_date
    assert_equal Time.zone.local(2020, 12, 31).end_of_day, Generation.new(32).end_date
  end

  test '#classmates' do
    assert_includes Generation.new(5).classmates, users(:komagata)
    assert_includes Generation.new(29).classmates, users(:jobseeker)
    users(:komagata).created_at = Time.zone.local(2020, 12, 31, 23, 59, 59)
    users(:komagata).save
    assert_includes Generation.new(32).classmates, users(:komagata)
    assert_not_includes Generation.new(33).classmates, users(:komagata)
  end

  test '#target_users' do
    assert_includes Generation.new(5).target_users('all'), users(:komagata)
    assert_includes Generation.new(5).target_users('retired'), users(:yameo)
    assert_not_includes Generation.new(5).target_users('retired'), users(:komagata)
    assert_not_includes Generation.new(5).target_users('all'), users(:yameo)
  end

  test '#user_status_counts' do
    assert_equal 14, Generation.new(5).user_status_counts[:students_and_trainees_count]
    assert_equal 2, Generation.new(5).user_status_counts[:graduates_count]
    assert_equal 2, Generation.new(5).user_status_counts[:retirees_count]
  end
end
