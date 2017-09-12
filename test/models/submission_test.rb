require "test_helper"

class SubmissionTest < ActiveSupport::TestCase
  def setup
    @tanaka_submission = submissions(:submission_1)
  end


  test "Should be valid submission" do
    assert @tanaka_submission.valid?
  end

  test "Should be user and practice with unique" do
    dup_request = @tanaka_submission.dup
    assert @tanaka_submission.valid?
    assert_not dup_request.valid?
  end

  test "Invalid submission user_id blank" do
    @tanaka_submission.user = nil
    assert_not @tanaka_submission.valid?
  end

  test "Invalid submission practice_id blank" do
    @tanaka_submission.practice_id = nil
    assert_not @tanaka_submission.valid?
  end

  test "Invalid submission passed nil" do
    @tanaka_submission.passed = nil
    assert_not @tanaka_submission.valid?
  end

  test "Invalid submission content nil" do
    @tanaka_submission.content = nil
    assert_not @tanaka_submission.valid?
  end

  test "Invalid submission content blank" do
    @tanaka_submission.content = ""
    assert_not @tanaka_submission.valid?
  end

  test "Invalid submission content short( 5 character )" do
    @tanaka_submission.content = "a" * 4
    assert_not @tanaka_submission.valid?
  end

  test "Invalid submission content long( 2000 character )" do
    @tanaka_submission.content = "a" * 2001
    assert_not @tanaka_submission.valid?
  end
end
