# frozen_string_literal: true

require "application_system_test_case"

class PaginateTest < ApplicationSystemTestCase
  setup { login_user "komagata", "testtest" }

  test "Show pagination in /users/:id/comments" do
    visit user_comments_path([users(:komagata)])
    assert_selector "span.thread-comments-container__title-count", text: "（1 〜 25 件を表示）"
    assert_selector "nav.pagination", count: 1
  end

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
