# frozen_string_literal: true

Rails.configuration.after_initialize do
  sad_streak_updater = SadStreakUpdater.new
  Newspaper.subscribe(:report_save, sad_streak_updater)
  Newspaper.subscribe(:report_destroy, sad_streak_updater)

  learning_cache_destroyer = LearningCacheDestroyer.new
  Newspaper.subscribe(:learning_create, learning_cache_destroyer)
  Newspaper.subscribe(:learning_destroy, learning_cache_destroyer)

  answer_cache_destroyer = AnswerCacheDestroyer.new
  Newspaper.subscribe(:answer_save, answer_cache_destroyer)
  Newspaper.subscribe(:answer_destroy, answer_cache_destroyer)
  Newspaper.subscribe(:correct_answer_save, CorrectAnswerNotifier.new)

  Newspaper.subscribe(:user_create, SignUpNotifier.new)
  Newspaper.subscribe(:student_or_trainee_create, TimesChannelCreator.new)

  Newspaper.subscribe(:regular_event_update, RegularEventUpdateNotifier.new)

  Newspaper.subscribe(:graduation_update, GraduationNotifier.new)

  Newspaper.subscribe(:comeback_update, ComebackNotifier.new)

  learning_status_updater = LearningStatusUpdater.new
  Newspaper.subscribe(:check_create, learning_status_updater)
  Newspaper.subscribe(:product_save, learning_status_updater)
  Newspaper.subscribe(:check_cancel, learning_status_updater)

  page_notifier = PageNotifier.new
  Newspaper.subscribe(:page_create, page_notifier)
  Newspaper.subscribe(:page_update, page_notifier)

  mentors_watch_for_question_creator = MentorsWatchForQuestionCreator.new
  Newspaper.subscribe(:question_create, mentors_watch_for_question_creator)
  Newspaper.subscribe(:question_update, mentors_watch_for_question_creator)

  ai_answer_creator = AIAnswerCreator.new
  Newspaper.subscribe(:question_create, ai_answer_creator)
  Newspaper.subscribe(:question_update, ai_answer_creator)

  Newspaper.subscribe(:retirement_create, UnfinishedDataDestroyer.new)
  Newspaper.subscribe(:retirement_create, TimesChannelDestroyer.new)

  question_notifier = QuestionNotifier.new
  Newspaper.subscribe(:question_create, question_notifier)
  Newspaper.subscribe(:question_update, question_notifier)

  Newspaper.subscribe(:product_update, ProductUpdateNotifierForWatcher.new)
  Newspaper.subscribe(:product_update, ProductUpdateNotifierForChecker.new)
  Newspaper.subscribe(:came_comment, CommentNotifier.new)
  Newspaper.subscribe(:came_comment_in_talk, CommentNotifierForAdmin.new)
end
