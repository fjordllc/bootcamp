# frozen_string_literal: true

Rails.configuration.after_initialize do
  answer_cache_destroyer = AnswerCacheDestroyer.new
  Newspaper.subscribe(:answer_save, answer_cache_destroyer)
  Newspaper.subscribe(:answer_destroy, answer_cache_destroyer)

  Newspaper.subscribe(:came_comment_in_talk, CommentNotifierForAdmin.new)
end
