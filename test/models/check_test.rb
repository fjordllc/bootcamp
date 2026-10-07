# frozen_string_literal: true

require 'test_helper'

class CheckTest < ActiveSupport::TestCase
  test 'checkable_class resolves supported types to their classes' do
    { 'Product' => Product, 'Report' => Report }.each do |type, klass|
      assert_equal klass, Check.checkable_class(type)
    end
  end

  test 'checkable_class returns nil for unsupported types' do
    ['User', 'Kernel', 'Object', 'UnknownResource', '', ' ', 'report', ' Report', 'Report ', '::Report', '123',
     :Report, ['Report'], { name: 'Report' }, 123, false, nil].each do |type|
      assert_nil Check.checkable_class(type), "Unexpected resolution for #{type.inspect}"
    end
  end

  test 'cannot create multiple checks for the same checkable even by different users' do
    report = Report.left_outer_joins(:checks).where(checks: { id: nil }).first

    Check.create!(user: users(:komagata), checkable: report)
    check = Check.new(user: users(:mentormentaro), checkable: report)

    assert_not check.valid?
    assert_includes check.errors[:checkable_id], 'はすでに存在します'
  end
end
