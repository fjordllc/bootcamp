# frozen_string_literal: true

require 'test_helper'

class CommentsControllerTest < ActionDispatch::IntegrationTest
  test 'destroy as Turbo Stream' do
    sign_in(:hajime)
    comment = users(:hajime).comments.create!(
      commentable: reports(:report1),
      description: '削除するコメントです'
    )

    assert_difference -> { Comment.count }, -1 do
      delete comment_path(comment), as: :turbo_stream
    end

    assert_response :ok
    assert_not Comment.exists?(comment.id)
    assert_turbo_stream action: 'remove', target: dom_id(comment)
  end

  test "destroy another user's comment as admin or mentor" do
    %i[adminonly mentormentaro].each do |user|
      sign_in(user)
      comment = users(:hajime).comments.create!(
        commentable: reports(:report1),
        description: '他人が削除するコメントです'
      )

      assert_difference -> { Comment.count }, -1 do
        delete comment_path(comment), as: :turbo_stream
      end

      assert_response :ok
      assert_not Comment.exists?(comment.id)
      assert_turbo_stream action: 'remove', target: dom_id(comment)
    end
  end

  test "destroy another user's comment as neither admin nor mentor" do
    sign_in(:hajime)
    another_user_comment = comments(:comment1)

    assert_no_difference -> { Comment.count } do
      delete comment_path(another_user_comment), as: :turbo_stream
    end

    assert_response :not_found
    assert Comment.exists?(another_user_comment.id)
  end

  test 'destroy without signing in' do
    comment = comments(:comment1)

    assert_no_difference -> { Comment.count } do
      delete comment_path(comment), as: :turbo_stream
    end

    assert_redirected_to root_path
    assert Comment.exists?(comment.id)
  end
end
