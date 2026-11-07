# frozen_string_literal: true

require 'test_helper'

class FollowingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @follower = users(:kimura)
    @followed = users(:hatsuno)
    @user = users(:kimura)
  end

  test 'POST /followings creates a following' do
    sign_in @user

    assert_difference 'Following.count' do
      post followings_path(id: @followed.id, format: :html), params: { watch: 'true' }
    end

    assert_response :ok
    assert @follower.following?(@followed)
    assert @follower.watching?(@followed)
  end

  test 'POST /followings creates a following without watching' do
    sign_in @user

    assert_difference 'Following.count' do
      post followings_path(id: @followed.id, format: :html), params: { watch: 'false' }
    end

    assert_response :ok
    assert @follower.following?(@followed)
    assert_not @follower.watching?(@followed)
  end

  test 'POST /followings when already following returns bad request' do
    sign_in @user
    @follower.follow(@followed, watch: true)

    assert_no_difference 'Following.count' do
      post followings_path(id: @followed.id, format: :html), params: { watch: 'false' }
    end

    assert_response :bad_request
    assert @follower.following?(@followed)
    assert @follower.watching?(@followed)
  end

  test 'DELETE /followings/:id.html destroy a following' do
    sign_in @user
    @follower.follow(@followed, watch: true)

    assert_difference 'Following.count', -1 do
      delete following_path(@followed, format: :html)
    end

    assert_response :ok
    assert_not @follower.following?(@followed)
  end

  test 'DELETE /followings/:id.html without following returns bad request' do
    sign_in @user
    other_following = users(:hajime).follow(@followed, watch: true)

    assert_no_difference 'Following.count' do
      delete following_path(@followed, format: :html)
    end

    assert_response :bad_request
    assert_not @follower.following?(@followed)
    assert other_following.reload.watch?
  end

  test 'PATCH /followings/:id.html updates watching' do
    sign_in @user
    following = @follower.follow(@followed, watch: true)
    other_following = users(:hajime).follow(@followed, watch: true)

    assert_no_difference 'Following.count' do
      patch following_path(@followed, format: :html), params: { watch: 'false' }
      assert_response :ok
      assert_not following.reload.watch?

      patch following_path(@followed, format: :html), params: { watch: 'true' }
      assert_response :ok
      assert following.reload.watch?
    end
    assert other_following.reload.watch?
  end

  test 'PATCH /followings/:id.html without following returns bad request' do
    sign_in @user
    other_following = users(:hajime).follow(@followed, watch: true)

    assert_no_difference 'Following.count' do
      patch following_path(@followed, format: :html), params: { watch: 'false' }
    end

    assert_response :bad_request
    assert_not @follower.following?(@followed)
    assert other_following.reload.watch?
  end

  test 'PATCH /followings/:id.html after unfollowing returns bad request' do
    sign_in @user
    @follower.follow(@followed, watch: true)
    @follower.unfollow(@followed)

    assert_no_difference 'Following.count' do
      patch following_path(@followed, format: :html), params: { watch: 'true' }
    end

    assert_response :bad_request
    assert_not @follower.following?(@followed)
  end
end
