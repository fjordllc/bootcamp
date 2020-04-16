# frozen_string_literal: true

require "test_helper"

class CommentTest < ActiveSupport::TestCase
  test ".users_who_commented" do
    report = reports(:report_4)
    users = report.comments.users_who_commented
    sorted_users = report.comments.order(created_at: :desc).map(&:user).uniq.reverse
    assert_equal users, sorted_users
  end

  test ".collect_latest_for_each_user" do
    report = reports(:report_4)
    comments = report.comments.collect_latest_for_each_user
    users = [users(:komagata), users(:machida), users(:sotugyou)]
    comment_for_each_user = users.map { |user| user.comments.where(commentable_id: report.id).order(created_at: :asc).last }
    sorted_comments = comment_for_each_user.sort_by { |comment| comment.created_at }
    assert_equal comments, sorted_comments
  end
end
