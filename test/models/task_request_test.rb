require "test_helper"

class TaskRequestTest < ActiveSupport::TestCase
  def setup
    @tanaka_task_request = task_requests(:task_request_1)
  end


  test "Should be valid task_request" do
    assert @tanaka_task_request.valid?
  end

  test "Should be user and practice with unique" do
    dup_request = @tanaka_task_request.dup
    assert @tanaka_task_request.valid?
    assert_not dup_request.valid?
  end

  test "Invalid task_request user_id blank" do
    @tanaka_task_request.user = nil
    assert_not @tanaka_task_request.valid?
  end

  test "Invalid task_request practice_id blank" do
    @tanaka_task_request.practice_id = nil
    assert_not @tanaka_task_request.valid?
  end

  test "Invalid task_request passed nil" do
    @tanaka_task_request.passed = nil
    assert_not @tanaka_task_request.valid?
  end

  test "Invalid task_request content nil" do
    @tanaka_task_request.content = nil
    assert_not @tanaka_task_request.valid?
  end

  test "Invalid task_request content blank" do
    @tanaka_task_request.content = ""
    assert_not @tanaka_task_request.valid?
  end

  test "Invalid task_request content short( 5 character )" do
    @tanaka_task_request.content = "a" * 4
    assert_not @tanaka_task_request.valid?
  end

  test "Invalid task_request content long( 2000 character )" do
    @tanaka_task_request.content = "a" * 2001
    assert_not @tanaka_task_request.valid?
  end
end
