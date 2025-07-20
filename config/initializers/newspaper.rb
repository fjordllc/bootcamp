# frozen_string_literal: true

Rails.configuration.after_initialize do
  answer_cache_destroyer = AnswerCacheDestroyer.new
  Newspaper.subscribe(:answer_save, answer_cache_destroyer)
  Newspaper.subscribe(:answer_destroy, answer_cache_destroyer)
  Newspaper.subscribe(:correct_answer_save, CorrectAnswerNotifier.new)

  Newspaper.subscribe(:graduation_update, GraduationNotifier.new)

  Newspaper.subscribe(:comeback_update, ComebackNotifier.new)

  mentors_watch_for_question_creator = MentorsWatchForQuestionCreator.new
  Newspaper.subscribe(:question_create, mentors_watch_for_question_creator)
  Newspaper.subscribe(:question_update, mentors_watch_for_question_creator)

  ai_answer_creator = AIAnswerCreator.new
  Newspaper.subscribe(:question_create, ai_answer_creator)
  Newspaper.subscribe(:question_update, ai_answer_creator)

  unfinished_data_destroyer = UnfinishedDataDestroyer.new
  Newspaper.subscribe(:retirement_create, unfinished_data_destroyer)
  Newspaper.subscribe(:training_completion_create, unfinished_data_destroyer)

  times_channel_destroyer = TimesChannelDestroyer.new
  Newspaper.subscribe(:retirement_create, times_channel_destroyer)
  Newspaper.subscribe(:training_completion_create, times_channel_destroyer)

  question_notifier = QuestionNotifier.new
  Newspaper.subscribe(:question_create, question_notifier)
  Newspaper.subscribe(:question_update, question_notifier)

  Newspaper.subscribe(:product_update, ProductUpdateNotifierForWatcher.new)
  Newspaper.subscribe(:came_comment_in_talk, CommentNotifierForAdmin.new)
end
