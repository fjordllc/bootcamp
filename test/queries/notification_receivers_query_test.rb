# frozen_string_literal: true

require 'test_helper'

class NotificationReceiversQueryTest < ActiveSupport::TestCase
  test 'for all' do
    target = NotificationReceiversQuery.new(target: 'all').call
    assert_includes(target, users(:kimura))
    assert_not_includes(target, users(:yameo))
  end

  test 'for students' do
    target = NotificationReceiversQuery.new(target: 'students').call
    assert_includes(target, users(:kimura))
    assert_includes(target, users(:komagata))
    assert_includes(target, users(:mentormentaro))
    assert_not_includes(target, users(:yameo))
    assert_not_includes(target, users(:sotugyou))
    assert_not_includes(target, users(:advijirou))
    assert_not_includes(target, users(:kensyu))
  end

  test 'for job_seekers' do
    target = NotificationReceiversQuery.new(target: 'job_seekers').call
    assert_includes(target, users(:jobseeker))
    assert_includes(target, users(:komagata))
    assert_includes(target, users(:sotugyou))
    assert_includes(target, users(:mentormentaro))
    assert_not_includes(target, users(:sotugyou_with_job))
    assert_not_includes(target, users(:kimura))
    assert_not_includes(target, users(:yameo))
  end

  test 'for none' do
    target = NotificationReceiversQuery.new(target: 'none').call
    assert_not_includes(target, users(:kimura))
    assert_not_includes(target, users(:jobseeker))
    assert_not_includes(target, users(:komagata))
    assert_not_includes(target, users(:mentormentaro))
    assert_not_includes(target, users(:sotugyou))
    assert_not_includes(target, users(:advijirou))
    assert_not_includes(target, users(:kensyu))
    assert_not_includes(target, users(:yameo))
  end
end
