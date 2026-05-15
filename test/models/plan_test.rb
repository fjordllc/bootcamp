# frozen_string_literal: true

require 'test_helper'

class PlanTest < ActiveSupport::TestCase
  test '.standard_plan' do
    VCR.use_cassette 'plan/list' do
      assert_equal 'スタンダードプラン', Plan.standard_plan['nickname']
    end
  end
end
