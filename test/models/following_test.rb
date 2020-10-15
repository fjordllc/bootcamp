# frozen_string_literal: true

require "test_helper"

class FollowingTest < ActiveSupport::TestCase
  setup do
    @following = Following.new(follower_id: users(:kimura).id, followed_id: users(:hatsuno).id)
  end

  test "should be valid" do
    assert @following.valid?
  end

  test "should require a follower_id" do
    @following.follower_id = nil
    assert_not @following.valid?
  end

  test "should require a followed_id" do
    @following.followed_id = nil
    assert_not @following.valid?
  end
end
