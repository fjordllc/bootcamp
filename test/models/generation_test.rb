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

  test '#users' do
    assert_includes Generation.new(5).users, users(:komagata)
    assert_includes Generation.new(29).users, users(:jobseeker)
    users(:komagata).created_at = Time.zone.local(2020, 12, 31, 23, 59, 59)
    users(:komagata).save
    assert_includes Generation.new(32).users, users(:komagata)
    assert_not_includes Generation.new(33).users, users(:komagata)
  end
end
