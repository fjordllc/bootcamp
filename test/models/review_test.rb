require "test_helper"

class ReviewTest < ActiveSupport::TestCase
  def setup
    @review = reviews(:komagata_review)
  end

  test "Should be valid review" do
    assert @review.valid?
  end

  test "Should be Invalid user_id blank" do
    @review.user_id = ""
    assert_not @review.valid?
  end

  test "Should be Invalid submission_id blank" do
    @review.submission_id = ""
    assert_not @review.valid?
  end

  test "Should be Invalid message blank" do
    @review.message = ""
    assert_not @review.valid?
  end

  test "Should be valid message to be 2000 character" do
    @review.message = "a" * 2000
    assert @review.valid?
  end

  test "Should be Invalid message to be long(maximum 2000)" do
    @review.message = "a" * 2001
    assert_not @review.valid?
  end
end
