# frozen_string_literal: true

Rails.application.reloader.to_prepare do
  ActiveSupport::Notifications.subscribe('answer.create', AnswererWatcher.new)
  ActiveSupport::Notifications.subscribe('answer.create', AnswerNotifier.new)
  ActiveSupport::Notifications.subscribe('answer.save', AnswerCacheDestroyer.new)
  ActiveSupport::Notifications.subscribe('answer.destroy', AnswerCacheDestroyer.new)
  ActiveSupport::Notifications.subscribe('answer.create', NotifierToWatchingUser.new)
  ActiveSupport::Notifications.subscribe('correct_answer.save', CorrectAnswerNotifier.new)
  ActiveSupport::Notifications.subscribe('event.create', EventOrganizerWatcher.new)
  ActiveSupport::Notifications.subscribe('regular_event.create', RegularEventOrganizerWatcher.new)
  negative_streak_updater = NegativeStreakUpdater.new
  ActiveSupport::Notifications.subscribe('report.create', negative_streak_updater)
  ActiveSupport::Notifications.subscribe('report.update', negative_streak_updater)
  ActiveSupport::Notifications.subscribe('report.destroy', negative_streak_updater)
  ActiveSupport::Notifications.subscribe('report.create', FirstReportNotifier.new)
  ActiveSupport::Notifications.subscribe('report.update', FirstReportNotifier.new)
  ActiveSupport::Notifications.subscribe('report.create', ReportNotifier.new)
  ActiveSupport::Notifications.subscribe('report.update', ReportNotifier.new)
  ActiveSupport::Notifications.subscribe('announcement.create', AnnouncementNotifier.new)
  ActiveSupport::Notifications.subscribe('announcement.update', AnnouncementNotifier.new)
  ActiveSupport::Notifications.subscribe('announcement.destroy', AnnouncementNotificationDestroyer.new)
  ActiveSupport::Notifications.subscribe('article.create', ArticleNotifier.new)
  ActiveSupport::Notifications.subscribe('article.destroy', ArticleNotificationDestroyer.new)
  ActiveSupport::Notifications.subscribe('work.create', WorkNotifier.new)
  ActiveSupport::Notifications.subscribe('work.destroy', WorkNotificationDestroyer.new)
  ActiveSupport::Notifications.subscribe('product.create', ProductAuthorWatcher.new)
  ActiveSupport::Notifications.subscribe('product.create', ProductNotifierForColleague.new)
  ActiveSupport::Notifications.subscribe('product.create', ProductNotifierForPracticeWatcher.new)
  ActiveSupport::Notifications.subscribe('came.inquiry', InquiryNotifier.new)
  ActiveSupport::Notifications.subscribe('regular_event.update', RegularEventUpdateNotifier.new)
  ActiveSupport::Notifications.subscribe('student_or_trainee.create', TimesChannelCreator.new)
  ActiveSupport::Notifications.subscribe('product.update', ProductUpdateNotifierForWatcher.new)
  ActiveSupport::Notifications.subscribe('product.update', ProductUpdateNotifierForChecker.new)
  ActiveSupport::Notifications.subscribe('came.comment', CommentNotifier.new)
  ActiveSupport::Notifications.subscribe('graduation.update', GraduationNotifier.new)
  ActiveSupport::Notifications.subscribe('comeback.update', ComebackNotifier.new)

  learning_status_updater = LearningStatusUpdater.new
  ActiveSupport::Notifications.subscribe('product.save', learning_status_updater)
  ActiveSupport::Notifications.subscribe('check.create', learning_status_updater)
  ActiveSupport::Notifications.subscribe('check.cancel', learning_status_updater)

  page_notifier = PageNotifier.new
  ActiveSupport::Notifications.subscribe('page.create', page_notifier)
  ActiveSupport::Notifications.subscribe('page.update', page_notifier)

  learning_cache_destroyer = LearningCacheDestroyer.new
  ActiveSupport::Notifications.subscribe('learning.create', learning_cache_destroyer)
  ActiveSupport::Notifications.subscribe('learning.destroy', learning_cache_destroyer)

  mentors_watch_for_question_creator = MentorsWatchForQuestionCreator.new
  ActiveSupport::Notifications.subscribe('question.create', mentors_watch_for_question_creator)
  ActiveSupport::Notifications.subscribe('question.update', mentors_watch_for_question_creator)

  ai_answer_creator = AiAnswerCreator.new
  ActiveSupport::Notifications.subscribe('question.create', ai_answer_creator)
  ActiveSupport::Notifications.subscribe('question.update', ai_answer_creator)

  question_notifier = QuestionNotifier.new
  ActiveSupport::Notifications.subscribe('question.create', question_notifier)
  ActiveSupport::Notifications.subscribe('question.update', question_notifier)

  unfinished_data_destroyer = UnfinishedDataDestroyer.new
  ActiveSupport::Notifications.subscribe('retirement.create', unfinished_data_destroyer)
  ActiveSupport::Notifications.subscribe('training_completion.create', unfinished_data_destroyer)

  times_channel_destroyer = TimesChannelDestroyer.new
  ActiveSupport::Notifications.subscribe('retirement.create', times_channel_destroyer)
  ActiveSupport::Notifications.subscribe('training_completion.create', times_channel_destroyer)
  ActiveSupport::Notifications.subscribe('student_or_trainee.create', TimesChannelCreator.new)
  ActiveSupport::Notifications.subscribe('user.create', SignUpNotifier.new)
  ActiveSupport::Notifications.subscribe('regular_event.update', RegularEventUpdateNotifier.new)

  watch_for_pair_work_creator = WatchForPairWorkCreator.new
  ActiveSupport::Notifications.subscribe('pair_work.create', watch_for_pair_work_creator)
  ActiveSupport::Notifications.subscribe('pair_work.update', watch_for_pair_work_creator)
  pair_work_notifier = PairWorkNotifier.new
  ActiveSupport::Notifications.subscribe('pair_work.create', pair_work_notifier)
  ActiveSupport::Notifications.subscribe('pair_work.update', pair_work_notifier)
  ActiveSupport::Notifications.subscribe('pair_work.update', PairWorkMatchingNotifier.new)
end
