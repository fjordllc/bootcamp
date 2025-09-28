# frozen_string_literal: true

Rails.configuration.after_initialize do
  unfinished_data_destroyer = UnfinishedDataDestroyer.new
  Newspaper.subscribe(:training_completion_create, unfinished_data_destroyer)

  times_channel_destroyer = TimesChannelDestroyer.new
  Newspaper.subscribe(:training_completion_create, times_channel_destroyer)

  Newspaper.subscribe(:came_comment_in_talk, CommentNotifierForAdmin.new)
end
