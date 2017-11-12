require "test_helper"

class ArtifactTest < ActiveSupport::TestCase
  def setup
    @artifact = artifacts(:artifact_1)
  end

  test "Should be valid artifact" do
    assert @artifact.valid?
  end

  test "Should be user and practice with unique" do
    dup_request = @artifact.dup
    assert @artifact.valid?
    assert_not dup_request.valid?
  end

  test "Invalid artifacts user_id blank" do
    @artifact.user = nil
    assert_not @artifact.valid?
  end

  test "Invalid artifacts practice_id blank" do
    @artifact.practice_id = nil
    assert_not @artifact.valid?
  end

  test "Invalid artifacts content nil" do
    @artifact.content = nil
    assert_not @artifact.valid?
  end

  test "Invalid artifacts content blank" do
    @artifact.content = ""
    assert_not @artifact.valid?
  end

  test "Invalid artifacts content short( 5 character )" do
    @artifact.content = "a" * 4
    assert_not @artifact.valid?
  end

  test "Invalid artifacts content long( 2000 character )" do
    @artifact.content = "a" * 2001
    assert_not @artifact.valid?
  end
end
