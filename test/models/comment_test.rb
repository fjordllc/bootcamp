# frozen_string_literal: true

require "test_helper"

class CommentTest < ActiveSupport::TestCase
  test "return grouped users" do
    report = reports(:report_4)
    users = report.comments.grouped_users
    sorted_users = report.comments.map(&:user).uniq
    assert_equal users, sorted_users
  end
end
