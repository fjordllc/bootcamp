# frozen_string_literal: true

require 'test_helper'

class API::FollowingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @follower = users(:kimura)
    @followed = users(:hatsuno)
    token = create_token('kimura', 'testtest')
    @headers = { 'Authorization' => "Bearer #{token}" }
  end

  test 'PATCH /api/followings/:id.json updates watching' do
    following = @follower.follow(@followed, watch: true)
    other_following = users(:hajime).follow(@followed, watch: true)

    assert_no_difference 'Following.count' do
      patch api_following_path(@followed, format: :json), params: { watch: 'false' }, headers: @headers
      assert_response :no_content
      assert_not following.reload.watch?

      patch api_following_path(@followed, format: :json), params: { watch: 'true' }, headers: @headers
      assert_response :no_content
      assert following.reload.watch?
    end
    assert other_following.reload.watch?
  end

  test 'PATCH /api/followings/:id.json without following returns bad request' do
    other_following = users(:hajime).follow(@followed, watch: true)

    assert_no_difference 'Following.count' do
      patch api_following_path(@followed, format: :json), params: { watch: 'false' }, headers: @headers
    end

    assert_response :bad_request
    assert_not @follower.following?(@followed)
    assert other_following.reload.watch?
  end

  test 'PATCH /api/followings/:id.json after unfollowing returns bad request' do
    @follower.follow(@followed, watch: true)
    @follower.unfollow(@followed)

    assert_no_difference 'Following.count' do
      patch api_following_path(@followed, format: :json), params: { watch: 'true' }, headers: @headers
    end

    assert_response :bad_request
    assert_not @follower.following?(@followed)
  end
end
