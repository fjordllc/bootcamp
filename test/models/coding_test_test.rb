# frozen_string_literal: true

require 'test_helper'

class CodingTestTest < ActiveSupport::TestCase
  test '#submitted_by?' do
    coding_test = coding_tests(:coding_test1)

    assert coding_test.submitted_by?(users(:hatsuno))
    assert_not coding_test.submitted_by?(users(:kimura))
  end
end
