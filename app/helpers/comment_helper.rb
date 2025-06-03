# frozen_string_literal: true

module CommentHelper
  def latest_comment?(comment, latest_comment)
  comment.id == latest_comment&.id
  end
end
