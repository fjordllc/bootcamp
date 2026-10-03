# frozen_string_literal: true

require 'test_helper'

class CommentsControllerTest < ActionDispatch::IntegrationTest
  test 'create as Turbo Stream' do
    sign_in(:hajime)
    report = reports(:report1)
    params = {
      commentable_type: Report.name,
      commentable_id: report.id,
      comment: { description: 'コメントを作成します' }
    }

    assert_difference -> { Comment.count }, 1 do
      post comments_path, params:, as: :turbo_stream
    end

    assert_response :ok

    comment = report.comments.order(:id).last
    assert_equal params.dig(:comment, :description), comment.description
    assert_equal users(:hajime), comment.user

    assert_turbo_stream action: 'append', target: dom_id(report, :comments) do
      assert_select "[data-comment-target='commentBody']", text: 'コメントを作成します'
    end
  end

  test 'create with invalid params' do
    sign_in(:hajime)
    report = reports(:report1)
    params = {
      commentable_type: Report.name,
      commentable_id: report.id,
      comment: { description: '' }
    }

    assert_no_difference -> { Comment.count } do
      post comments_path, params:, as: :turbo_stream
    end

    assert_response :unprocessable_entity
  end

  test 'create without signing in' do
    report = reports(:report1)
    params = {
      commentable_type: Report.name,
      commentable_id: report.id,
      comment: { description: 'コメントを作成します' }
    }

    assert_no_difference -> { Comment.count } do
      post comments_path, params:, as: :turbo_stream
    end

    assert_redirected_to root_path
  end

  test 'update as Turbo Stream' do
    sign_in(:hajime)
    comment = users(:hajime).comments.create!(
      commentable: reports(:report1),
      description: '更新するコメントです'
    )
    params = { comment: { description: '更新後のコメントです' } }

    patch comment_path(comment), params:, as: :turbo_stream

    assert_response :ok
    assert_equal '更新後のコメントです', comment.reload.description
    assert_turbo_stream action: 'replace', target: dom_id(comment) do
      assert_select "[data-comment-target='commentBody']", text: '更新後のコメントです'
    end
  end

  test "update another user's comment as admin or mentor" do
    %i[adminonly mentormentaro].each do |user|
      sign_in(user)
      comment = users(:hajime).comments.create!(
        commentable: reports(:report1),
        description: '他人が更新するコメントです'
      )
      params = { comment: { description: '更新後のコメントです' } }

      patch comment_path(comment), params:, as: :turbo_stream

      assert_response :ok
      assert_equal '更新後のコメントです', comment.reload.description
      assert_turbo_stream action: 'replace', target: dom_id(comment) do
        assert_select "[data-comment-target='commentBody']", text: '更新後のコメントです'
      end
    end
  end

  test "update another user's comment as neither admin nor mentor" do
    sign_in(:hajime)
    comment = comments(:comment1)
    params = { comment: { description: '更新後のコメントです' } }

    patch comment_path(comment), params:, as: :turbo_stream

    assert_response :not_found
    assert_equal 'CSSは奥が深いですね。', comment.reload.description
  end

  test 'update without signing in' do
    comment = comments(:comment1)
    params = { comment: { description: '更新後のコメントです' } }

    patch comment_path(comment), params:, as: :turbo_stream

    assert_equal 'CSSは奥が深いですね。', comment.reload.description
    assert_redirected_to root_path
  end

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
