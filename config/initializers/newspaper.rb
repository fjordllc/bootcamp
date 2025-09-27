# frozen_string_literal: true

Rails.configuration.after_initialize do
  Newspaper.subscribe(:correct_answer_save, CorrectAnswerNotifier.new)

  Newspaper.subscribe(:graduation_update, GraduationNotifier.new)

  Newspaper.subscribe(:comeback_update, ComebackNotifier.new)

  unfinished_data_destroyer = UnfinishedDataDestroyer.new
  Newspaper.subscribe(:retirement_create, unfinished_data_destroyer)
  Newspaper.subscribe(:training_completion_create, unfinished_data_destroyer)

  times_channel_destroyer = TimesChannelDestroyer.new
  Newspaper.subscribe(:retirement_create, times_channel_destroyer)
  Newspaper.subscribe(:training_completion_create, times_channel_destroyer)

  Newspaper.subscribe(:came_comment_in_talk, CommentNotifierForAdmin.new)
end
