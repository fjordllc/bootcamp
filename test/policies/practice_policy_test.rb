# frozen_string_literal: true

require 'test_helper'

class PracticePolicyTest < ActiveSupport::TestCase
  test '#show_memo? allows mentors and admins, including admin-only users' do
    assert policy(users(:mentormentaro)).show_memo?
    assert policy(users(:adminonly)).show_memo?
  end

  test '#show_memo? denies nil, advisers, students, trainees, and graduates' do
    assert_not policy(nil).show_memo?
    %i[advijirou kimura kensyu sotugyou].each do |fixture_name|
      assert_not policy(users(fixture_name)).show_memo?, fixture_name.to_s
    end
  end

  test '#show_memo? remains independent of inactive account status' do
    mentor = users(:mentormentaro)

    [
      { hibernated_at: Time.current },
      { training_completed_at: Time.current },
      { retired_on: Date.current }
    ].each do |inactive_attributes|
      mentor.update!(inactive_attributes)

      assert policy(mentor).show_memo?, inactive_attributes.keys.first.to_s

      mentor.update!(hibernated_at: nil, training_completed_at: nil, retired_on: nil)
    end
  end

  test '#show? keeps its existing access rule' do
    practice = Practice.new

    assert PracticePolicy.new(users(:advijirou), practice).show?
  end

  private

  def policy(user)
    PracticePolicy.new(user, Practice.new)
  end
end
