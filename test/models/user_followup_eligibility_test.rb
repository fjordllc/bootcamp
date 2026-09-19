# frozen_string_literal: true

require 'test_helper'

class UserFollowupEligibilityTest < ActiveSupport::TestCase
  def build_student(created_at:, hibernated_at: nil, sent_student_followup_message: false, admin: false)
    User.new(created_at:, hibernated_at:, sent_student_followup_message:, admin:)
  end

  test '#eligible? is true for a student who registered over 29 days ago' do
    travel_to Time.zone.local(2020, 2, 1) do
      student = build_student(created_at: 30.days.ago)
      assert UserFollowupEligibility.new(student).eligible?
    end
  end

  test '#eligible? is false right at the 29 day boundary' do
    travel_to Time.zone.local(2020, 2, 1) do
      student = build_student(created_at: 29.days.ago)
      assert_not UserFollowupEligibility.new(student).eligible?
    end
  end

  test '#eligible? is false for a recently registered student' do
    travel_to Time.zone.local(2020, 2, 1) do
      student = build_student(created_at: 1.day.ago)
      assert_not UserFollowupEligibility.new(student).eligible?
    end
  end

  test '#eligible? is false for a hibernated student' do
    travel_to Time.zone.local(2020, 2, 1) do
      student = build_student(created_at: 30.days.ago, hibernated_at: 1.day.ago)
      assert_not UserFollowupEligibility.new(student).eligible?
    end
  end

  test '#eligible? is false when the followup message was already sent' do
    travel_to Time.zone.local(2020, 2, 1) do
      student = build_student(created_at: 30.days.ago, sent_student_followup_message: true)
      assert_not UserFollowupEligibility.new(student).eligible?
    end
  end

  test '#eligible? is false for an admin even when other conditions are met' do
    travel_to Time.zone.local(2020, 2, 1) do
      admin = build_student(created_at: 30.days.ago, admin: true)
      assert_not UserFollowupEligibility.new(admin).eligible?
    end
  end
end
