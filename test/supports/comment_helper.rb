# frozen_string_literal: true

module CommentHelper
  def post_comment(comment)
    wait_for_comments

    assert_selector('textarea[name="new_comment[description]"]')

    fill_in('new_comment[description]', with: comment)
    click_button 'コメントする'
  end

  def wait_for_comment_form
    wait_for_comments
    assert_selector('textarea[name="new_comment[description]"]')
  end

  def wait_for_comments
    assert_selector '#comments.loaded'
  end
end
