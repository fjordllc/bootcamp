# frozen_string_literal: true

Rails.configuration.after_initialize do
  Newspaper.subscribe(:came_comment_in_talk, CommentNotifierForAdmin.new)
end
