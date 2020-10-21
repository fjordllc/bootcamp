# frozen_string_literal: true

require "test_helper"

class GenerationTest < ActiveSupport::TestCase
  test "#start_date" do
    assert_equal Date.new(2013, 1, 1), Generation.new(1).start_date
    assert_equal Date.new(2013, 4, 1), Generation.new(2).start_date
  end

  test "#users" do
    assert_includes Generation.new(5).users, users(:komagata)
    assert_includes Generation.new(29).users, users(:daimyo)
  end
end
