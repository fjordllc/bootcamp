# frozen_string_literal: true

require "application_system_test_case"

class UserCommentListTest < ApplicationSystemTestCase
  test "show all comments for reports of the target user" do
    login_user "komagata", "testtest"
    visit polymorphic_path([users(:komagata), :comments])
    assert_equal 3, users(:komagata).comments.where(commentable_type: "Report").size
  end
end
