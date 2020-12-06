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
end
