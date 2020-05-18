# frozen_string_literal: true

require "test_helper"

class LearningTest < ActiveSupport::TestCase
  test "valid is_startable_practice" do
    learning = learnings(:learning_3)
    assert learning.valid?

    learning.status = "started"
    assert_not learning.valid?
  end
end
