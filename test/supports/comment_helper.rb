# frozen_string_literal: true

module CommentHelper
  def post_comment(comment)
    # Wait for Vue.js comment component to be fully initialized
    assert_selector('#comments.loaded')

    # Wait for the comment form field to be available and enabled
    assert_selector('textarea[name="new_comment[description]"]')

    fill_in('new_comment[description]', with: comment)
    click_button 'コメントする'
  end

  def wait_for_comment_form
    # Ensure the comment form is fully loaded and ready
    assert_selector('#comments.loaded')
    assert_selector('textarea[name="new_comment[description]"]')
  end
end
