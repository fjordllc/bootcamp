# frozen_string_literal: true

module CommentHelper
  def post_comment(comment)
    fill_in('new_comment[description]', with: comment)
    click_button 'コメントする'
  end
end
