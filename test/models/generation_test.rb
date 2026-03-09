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

  test '#count_classmates_by_target' do
    fifth_generation_users = User.where(created_at: '2014-01-01 00:00:00'..'2014-03-31 23:59:59')
    fifth_generation_students_count = fifth_generation_users.where(
      admin: false,
      mentor: false,
      adviser: false,
      trainee: false,
      hibernated_at: nil,
      retired_on: nil,
      graduated_on: nil
    ).count
    fifth_generation_trainees_count = fifth_generation_users.where(
      trainee: true,
      training_completed_at: nil
    ).count
    fifth_generation_hibernated_users_count = fifth_generation_users.where.not(hibernated_at: nil).count
    fifth_generation_graduated_users_count = fifth_generation_users.where.not(graduated_on: nil).count
    fifth_generation_advisers_count = fifth_generation_users.where(adviser: true).count
    fifth_generation_retired_users_count = fifth_generation_users.where.not(retired_on: nil).count

    assert_equal fifth_generation_students_count, Generation.new(5).count_classmates_by_target(:students)
    assert_equal fifth_generation_trainees_count, Generation.new(5).count_classmates_by_target(:trainees)
    assert_equal fifth_generation_hibernated_users_count, Generation.new(5).count_classmates_by_target(:hibernated)
    assert_equal fifth_generation_graduated_users_count, Generation.new(5).count_classmates_by_target(:graduated)
    assert_equal fifth_generation_advisers_count, Generation.new(5).count_classmates_by_target(:advisers)
    assert_equal fifth_generation_retired_users_count, Generation.new(5).count_classmates_by_target(:retired)
  end
end
