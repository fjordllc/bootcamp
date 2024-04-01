# frozen_string_literal: true

module CommentsHelper
  def user_comments_page?
    controller_path == 'users/comments' && action_name == 'index'
  end

  def comments_props(title:, commentable_id:, commentable_type:)
    user = current_user.as_json(only: %i[id login_name], methods: %i[avatar_url roles primary_role icon_title])
    { title:, commentableId: commentable_id, commentableType: commentable_type, currentUser: user, availableEmojis: Reaction.available_emojis.to_json }
  end
end
