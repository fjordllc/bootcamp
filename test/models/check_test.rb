# frozen_string_literal: true

require 'test_helper'

class CheckTest < ActiveSupport::TestCase
  test 'cannot create multiple checks for the same checkable even by different users' do
    report = Report.left_outer_joins(:checks).where(checks: { id: nil }).first

    Check.create!(user: users(:komagata), checkable: report)
    check = Check.new(user: users(:mentormentaro), checkable: report)

    assert_not check.valid?
    assert_includes check.errors[:checkable_id], 'はすでに存在します'
  end
end
