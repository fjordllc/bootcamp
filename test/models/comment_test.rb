# frozen_string_literal: true

require "test_helper"

class CommentTest < ActiveSupport::TestCase
  test "return users by recent grouped by user" do
    report = reports(:report_4)
    users = report.comments.recent_unique_users
    sorted_users = report.comments.order(created_at: :desc).map(&:user).uniq.reverse
    assert_equal users, sorted_users
  end
end
