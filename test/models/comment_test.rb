# frozen_string_literal: true

require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  test '.commented_users' do
    report = reports(:report4)
    users = report.comments.commented_users
    sorted_users = report.comments.order(created_at: :desc).map(&:user).uniq.reverse
    assert_equal users, sorted_users
  end

  test '#anchor' do
    comment = comments(:comment1)
    assert_equal "comment_#{comment.id}", comment.anchor
  end

  test '#path' do
    comment = comments(:comment1)
    commentable = comment.commentable
    assert_equal "/reports/#{commentable.id}#comment_#{comment.id}", comment.path
  end

  test 'do not send notification if you post a mention in talks' do
    kimura = users(:kimura)
    kimura_talk = talks(:talk7)

    Comment.create!(
      user: kimura,
      commentable: kimura_talk,
      description: '@hatsuno test'
    )

    assert_not users(:hatsuno).notifications.exists?(
      kind: 'mentioned',
      sender: kimura
    )
  end
end
