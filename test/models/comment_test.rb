# frozen_string_literal: true

require "test_helper"

class CommentTest < ActiveSupport::TestCase
  test ".commented_users" do
    report = reports(:report_4)
    users = report.comments.commented_users
    sorted_users = report.comments.order(created_at: :desc).map(&:user).uniq.reverse
    assert_equal users, sorted_users
  end
end
