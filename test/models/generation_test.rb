# frozen_string_literal: true

require "test_helper"

class GenerationTest < ActiveSupport::TestCase
  test "#start_date" do
    assert_equal Date.new(2013, 1, 1), Generation.start_date(1)
    assert_equal Date.new(2013, 4, 1), Generation.start_date(2)
  end
end
