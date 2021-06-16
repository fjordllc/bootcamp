# frozen_string_literal: true

require 'test_helper'

class PlanTest < ActiveSupport::TestCase
  test '.standard_plan' do
    plan = Plan.standard_plan
    assert_equal 'スタンダードプラン', plan['nickname']
  end
end
