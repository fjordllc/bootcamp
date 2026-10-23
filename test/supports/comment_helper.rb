# frozen_string_literal: true

module CommentHelper
  def post_comment(comment)
    wait_for_comments

    assert_selector('textarea[name="comment[description]"]')

    fill_in('comment[description]', with: comment)
    click_button 'コメントする'
  end

  def wait_for_comment_form
    wait_for_comments
    assert_selector('textarea[name="comment[description]"]')
  end

  def wait_for_comments
    assert_selector '#comments.loaded'
  end
end
