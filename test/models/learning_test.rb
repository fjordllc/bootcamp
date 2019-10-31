# frozen_string_literal: true

require "test_helper"

class LearningTest < ActiveSupport::TestCase
  test "product_submitted" do
    learning = learnings(:learning_1)
    learning.product_submitted
    assert_equal learning.status, "submitted"

    learning = learnings(:learning_2)
    learning.product_submitted
    assert_equal learning.status, "complete"
  end

  test "product_confirmed" do
    learning = learnings(:learning_1)
    learning.product_confirmed
    assert_equal learning.status, "complete"
  end
end
