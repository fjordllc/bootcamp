# frozen_string_literal: true

require "application_system_test_case"

class CommentsTest < ApplicationSystemTestCase
  setup { login_user "komagata", "testtest" }

  test "show all comments for reports of the target user" do
    visit polymorphic_path([users(:komagata), :comments])
    assert_equal 3, users(:komagata).comments.where(commentable_type: "Report").size
  end

  test "comment form not found in /users/:user_id/comments" do
    visit user_comments_path(users(:komagata))
    assert has_no_field?("comment[description]")
  end

  test "comment form found in /reports/:report_id" do
    visit report_path(users(:komagata).reports.first)
    assert has_field?("comment[description]")
  end
end
