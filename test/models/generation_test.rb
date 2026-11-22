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

  test '#target_users returns only users of the target role' do
    {
      'trainee' => :kensyu,
      'adviser' => :advijirou,
      'graduate' => :sotugyou,
      'mentor' => :mentormentaro
    }.each do |target, login_name|
      target_users = Generation.new(5).target_users(target)

      assert_includes target_users, users(login_name), "#{target}に#{login_name}が含まれること"
      assert_not_includes target_users, users(:yameo), "#{target}に退会者が含まれないこと"
      assert_not_includes target_users, users(:kimura), "#{target}に現役生が含まれないこと"
    end
  end

  test '.generations returns only generations that have target users' do
    travel_to Time.zone.local(2014, 4, 1, 0, 0, 0) do
      %w[trainee adviser graduate mentor retired].each do |target|
        assert_includes Generation.generations(target).map(&:number), 5, "#{target}の5期生が含まれること"
      end
    end
  end

  test '#count_classmates_by_target' do
    expected = {
      students: 18,
      trainees: 3,
      hibernated: 1,
      graduated: 2,
      advisers: 3,
      retired: 1
    }
    gen5 = Generation.new(5)
    actual = expected.keys.index_with { |t| gen5.count_classmates_by_target(t) }
    assert_equal expected, actual
  end
end
