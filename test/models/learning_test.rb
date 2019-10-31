# frozen_string_literal: true

require "test_helper"

class LearningTest < ActiveSupport::TestCase
  test "status_to_submitted" do
    learning = learnings(:learning_1)
    learning.status_to_submitted
    assert_equal learning.status, "submitted"

    learning = learnings(:learning_2)
    learning.status_to_submitted
    assert_equal learning.status, "complete"
  end
end
