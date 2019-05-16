# frozen_string_literal: true

module CommentsHelper
  def user_comments_page?
    controller_path == "users/comments" && action_name == "index"
  end
end
