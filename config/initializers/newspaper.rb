# frozen_string_literal: true

Rails.application.config.after_initialize do
  Newspaper.subscribe(:event_create, EventOrganizerWatcher.new)
  Newspaper.subscribe(:answer_create, AnswerNotifier.new)
  Newspaper.subscribe(:answer_create, NotifierToWatchingUser.new)
  Newspaper.subscribe(:announcement_destroy, AnnouncementNotificationDestroyer.new)
  Newspaper.subscribe(:answer_create, AnswererWatcher.new)

  announcement_notifier = AnnouncementNotifier.new
  Newspaper.subscribe(:announcement_create, announcement_notifier)
  Newspaper.subscribe(:announcement_update, announcement_notifier)

  sad_streak_updater = SadStreakUpdater.new
  Newspaper.subscribe(:report_save, sad_streak_updater)
  Newspaper.subscribe(:report_destroy, sad_streak_updater)

  Newspaper.subscribe(:report_save, FirstReportNotifier.new)
  Newspaper.subscribe(:report_save, ReportNotifier.new)

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

  Newspaper.subscribe(:product_create, ProductAuthorWatcher.new)

  learning_status_updater = LearningStatusUpdater.new
  Newspaper.subscribe(:check_create, learning_status_updater)
  Newspaper.subscribe(:product_save, learning_status_updater)

  page_notifier = PageNotifier.new
  Newspaper.subscribe(:page_create, page_notifier)
  Newspaper.subscribe(:page_update, page_notifier)

  Newspaper.subscribe(:product_save, ProductNotifierForColleague.new)

  Newspaper.subscribe(:product_save, ProductNotifierForPracticeWatcher.new)

  mentors_watch_for_question_creator = MentorsWatchForQuestionCreator.new
  Newspaper.subscribe(:question_create, mentors_watch_for_question_creator)
  Newspaper.subscribe(:question_update, mentors_watch_for_question_creator)

  ai_answer_creator = AIAnswerCreator.new
  Newspaper.subscribe(:question_create, ai_answer_creator)
  Newspaper.subscribe(:question_update, ai_answer_creator)

  Newspaper.subscribe(:retirement_create, UnfinishedDataDestroyer.new)

  question_notifier = QuestionNotifier.new
  Newspaper.subscribe(:question_create, question_notifier)
  Newspaper.subscribe(:question_update, question_notifier)

  Newspaper.subscribe(:product_update, ProductUpdateNotifier.new)
end
