# frozen_string_literal: true

require "application_system_test_case"

class PaginateTest < ApplicationSystemTestCase
  setup { login_user "komagata", "testtest" }

  test "GET /users/:id/comments" do
    visit user_comments_path([users(:komagata)])
    assert_equal 25, users(:komagata).comments.page(1).size
  end

  test "GET /users/:id/comments?page=3" do
    url = user_comments_path([users(:komagata)])
    visit "#{url}?page=3"
    assert_equal 25, users(:komagata).comments.page(3).size
  end
end
