# 死蔵コード台帳

生成日: 2026-06-17

## 前提

この台帳は削除対象の確定リストではなく、後続の削除フェーズで確認する候補リスト。
Rails の動的呼び出し、メタプログラミング、文字列経由の `render`、ViewComponent などにより false positive が含まれる。
削除前に個別に参照経路を確認し、関連テストと system test で振る舞いを確認する。

## 再生成方法

```bash
mise exec -- script/refactoring/dead_code_inventory
```

## ルーティング・アクション候補

実行コマンド: `bin/rails traceroute`

```text
Unused routes (0):

Unreachable action methods (0):
```



## 未使用メソッド候補

実行コマンド: `bundle exec debride app lib`

```text
These methods MIGHT not be called:

API::Admin::CountController
  show                                app/controllers/api/admin/count_controller.rb:4-16 (13)

API::AnswersController
  set_answer                          app/controllers/api/answers_controller.rb:56-59 (4)

API::BaseController
  doorkeeper_forbidden_render_options app/controllers/api/base_controller.rb:69-71 (3)
  doorkeeper_unauthorized_render_options app/controllers/api/base_controller.rb:65-67 (3)
  render_doorkeeper_error             app/controllers/api/base_controller.rb:73-76 (4)
  require_login_for_api               app/controllers/api/base_controller.rb:60-63 (4)

API::BuzzesController
  show                                app/controllers/api/buzzes_controller.rb:7-16 (10)

API::CheckableCheck
  require_staff                       app/controllers/concerns/api/checkable_check.rb:36-38 (3)
  set_checkable                       app/controllers/concerns/api/checkable_check.rb:40-43 (4)

API::CommentsController
  set_my_comment                      app/controllers/api/comments_controller.rb:55-58 (4)

API::CorrectAnswersController
  set_question                        app/controllers/api/correct_answers_controller.rb:27-29 (3)

API::MarkdownTasksController
  set_taskable                        app/controllers/api/markdown_tasks_controller.rb:22-28 (7)

API::MentorMemosController
  set_user                            app/controllers/api/mentor_memos_controller.rb:19-21 (3)

API::MicroReportsController
  set_micro_report                    app/controllers/api/micro_reports_controller.rb:16-23 (8)

API::MoviesController
  set_movie                           app/controllers/api/movies_controller.rb:18-20 (3)

API::PagesController
  set_page                            app/controllers/api/pages_controller.rb:16-18 (3)

API::Practices::LearningController
  show                                app/controllers/api/practices/learning_controller.rb:6-15 (10)

API::PracticesController
  set_practice                        app/controllers/api/practices_controller.rb:32-34 (3)
  show                                app/controllers/api/practices_controller.rb:11-11 (1)

API::Products::CheckerController
  set_product                         app/controllers/api/products/checker_controller.rb:41-43 (3)
  show                                app/controllers/api/products/checker_controller.rb:10-15 (6)

API::Products::PassedController
  show                                app/controllers/api/products/passed_controller.rb:4-13 (10)

API::Products::UnassignedController
  counts                              app/controllers/api/products/unassigned_controller.rb:15-24 (10)

API::ProductsController
  authorize_product                   app/controllers/api/products_controller.rb:71-76 (6)
  set_product                         app/controllers/api/products_controller.rb:66-69 (4)
  show                                app/controllers/api/products_controller.rb:21-23 (3)

API::PubSubController
  authenticate_pubsub_token           app/controllers/api/pub_sub_controller.rb:27-34 (8)

API::QuestionsController
  show                                app/controllers/api/questions_controller.rb:27-29 (3)

API::ReactionsController
  set_reactionable                    app/controllers/api/reactions_controller.rb:33-36 (4)

API::ReportTemplatesController
  set_report_template                 app/controllers/api/report_templates_controller.rb:30-32 (3)

API::Reports::ReactionsController
  set_report                          app/controllers/api/reports/reactions_controller.rb:33-36 (4)

API::Reports::UncheckedController
  counts                              app/controllers/api/reports/unchecked_controller.rb:9-13 (5)

API::ReportsController
  set_editable_report                 app/controllers/api/reports_controller.rb:78-81 (4)
  set_my_report                       app/controllers/api/reports_controller.rb:73-76 (4)
  show                                app/controllers/api/reports_controller.rb:21-23 (3)

API::Users::SupportContextsController
  require_admin_or_mentor             app/controllers/api/users/support_contexts_controller.rb:24-26 (3)
  set_user                            app/controllers/api/users/support_contexts_controller.rb:28-31 (4)
  show                                app/controllers/api/users/support_contexts_controller.rb:9-20 (12)

API::UsersController
  set_user                            app/controllers/api/users_controller.rb:78-84 (7)
  show                                app/controllers/api/users_controller.rb:28-33 (6)

ActionCompletedButtonComponent
  is_action_completed                 app/components/action_completed_button_component.rb:12 (1)
  update_path                         app/components/action_completed_button_component.rb:12 (1)

ActivityAsyncAdapter
  enqueue                             app/models/activity_async_adapter.rb:8-11 (4)

ActivityJob
  perform                             app/jobs/activity_job.rb:6-8 (3)

ActivityMailer
  added_work                          app/mailers/activity_mailer.rb:457-471 (15)
  assigned_as_checker                 app/mailers/activity_mailer.rb:265-280 (16)
  came_answer                         app/mailers/activity_mailer.rb:76-87 (12)
  came_comment                        app/mailers/activity_mailer.rb:43-57 (15)
  came_pair_work                      app/mailers/activity_mailer.rb:473-489 (17)
  came_question                       app/mailers/activity_mailer.rb:123-139 (17)
  cancel_pair_work                    app/mailers/activity_mailer.rb:551-567 (17)
  chose_correct_answer                app/mailers/activity_mailer.rb:407-421 (15)
  comebacked                          app/mailers/activity_mailer.rb:27-40 (14)
  consecutive_negative_report         app/mailers/activity_mailer.rb:334-348 (15)
  create_article                      app/mailers/activity_mailer.rb:441-454 (14)
  create_page                         app/mailers/activity_mailer.rb:193-208 (16)
  following_report                    app/mailers/activity_mailer.rb:226-242 (17)
  matching_pair_work                  app/mailers/activity_mailer.rb:491-510 (20)
  mentioned                           app/mailers/activity_mailer.rb:176-190 (15)
  moved_up_event_waiting_user         app/mailers/activity_mailer.rb:210-224 (15)
  no_correct_answer                   app/mailers/activity_mailer.rb:368-383 (16)
  product_update                      app/mailers/activity_mailer.rb:424-438 (15)
  rematching_pair_work                app/mailers/activity_mailer.rb:512-530 (19)
  reschedule_pair_work                app/mailers/activity_mailer.rb:532-549 (18)
  signed_up                           app/mailers/activity_mailer.rb:386-404 (19)
  submitted                           app/mailers/activity_mailer.rb:90-104 (15)
  training_completed                  app/mailers/activity_mailer.rb:300-314 (15)
  update_regular_event                app/mailers/activity_mailer.rb:351-365 (15)
  watching_notification               app/mailers/activity_mailer.rb:245-262 (18)

ActivityNotifier
  added_work                          app/notifiers/activity_notifier.rb:470-484 (15)
  assigned_as_checker                 app/notifiers/activity_notifier.rb:37-50 (14)
  came_answer                         app/notifiers/activity_notifier.rb:235-247 (13)
  came_comment                        app/notifiers/activity_notifier.rb:52-67 (16)
  came_inquiry                        app/notifiers/activity_notifier.rb:486-500 (15)
  came_pair_work                      app/notifiers/activity_notifier.rb:359-372 (14)
  came_question                       app/notifiers/activity_notifier.rb:69-82 (14)
  cancel_pair_work                    app/notifiers/activity_notifier.rb:424-438 (15)
  chose_correct_answer                app/notifiers/activity_notifier.rb:344-357 (14)
  comebacked                          app/notifiers/activity_notifier.rb:174-187 (14)
  consecutive_negative_report         app/notifiers/activity_notifier.rb:22-35 (14)
  create_article                      app/notifiers/activity_notifier.rb:455-468 (14)
  create_page                         app/notifiers/activity_notifier.rb:99-112 (14)
  following_report                    app/notifiers/activity_notifier.rb:220-233 (14)
  matching_pair_work                  app/notifiers/activity_notifier.rb:374-390 (17)
  mentioned                           app/notifiers/activity_notifier.rb:205-218 (14)
  moved_up_event_waiting_user         app/notifiers/activity_notifier.rb:440-453 (14)
  no_correct_answer                   app/notifiers/activity_notifier.rb:329-342 (14)
  product_update                      app/notifiers/activity_notifier.rb:281-294 (14)
  rematching_pair_work                app/notifiers/activity_notifier.rb:392-406 (15)
  reschedule_pair_work                app/notifiers/activity_notifier.rb:408-422 (15)
  signed_up                           app/notifiers/activity_notifier.rb:189-203 (15)
  submitted                           app/notifiers/activity_notifier.rb:84-97 (14)
  training_completed                  app/notifiers/activity_notifier.rb:129-142 (14)
  update_regular_event                app/notifiers/activity_notifier.rb:313-327 (15)
  watching_notification               app/notifiers/activity_notifier.rb:296-311 (16)

ActivityTimesHelper
  clamp_day_index                     app/helpers/activity_times_helper.rb:13-15 (3)
  clamp_hour                          app/helpers/activity_times_helper.rb:17-19 (3)
  format_time_range                   app/helpers/activity_times_helper.rb:7-11 (5)

Admin::CampaignsController
  edit                                app/controllers/admin/campaigns_controller.rb:30-30 (1)
  new                                 app/controllers/admin/campaigns_controller.rb:6-13 (8)
  set_campaign                        app/controllers/admin/campaigns_controller.rb:42-44 (3)

Admin::CompaniesController
  edit                                app/controllers/admin/companies_controller.rb:27-27 (1)
  new                                 app/controllers/admin/companies_controller.rb:13-15 (3)
  set_company                         app/controllers/admin/companies_controller.rb:49-51 (3)

Admin::CorporateTrainingInquiriesController
  show                                app/controllers/admin/corporate_training_inquiries_controller.rb:10-13 (4)

Admin::CourseDiffsController
  show                                app/controllers/admin/course_diffs_controller.rb:13-13 (1)

Admin::FAQCategories::FaqsController
  set_faq_category                    app/controllers/admin/faq_categories/faqs_controller.rb:18-20 (3)

Admin::FAQCategoriesController
  edit                                app/controllers/admin/faq_categories_controller.rb:24-24 (1)
  new                                 app/controllers/admin/faq_categories_controller.rb:10-12 (3)
  set_faq_category                    app/controllers/admin/faq_categories_controller.rb:50-52 (3)

Admin::FaqsController
  edit                                app/controllers/admin/faqs_controller.rb:24-24 (1)
  new                                 app/controllers/admin/faqs_controller.rb:9-11 (3)
  set_faq                             app/controllers/admin/faqs_controller.rb:45-47 (3)
  set_faq_category                    app/controllers/admin/faqs_controller.rb:49-51 (3)
  show                                app/controllers/admin/faqs_controller.rb:23-23 (1)

Admin::GrantCourseApplicationsController
  show                                app/controllers/admin/grant_course_applications_controller.rb:10-12 (3)

Admin::InquiriesController
  show                                app/controllers/admin/inquiries_controller.rb:11-14 (4)

Admin::Users::PasswordController
  edit                                app/controllers/admin/users/password_controller.rb:6-6 (1)
  set_user                            app/controllers/admin/users/password_controller.rb:25-27 (3)

Admin::Users::PracticeProgressBatchesController
  set_user                            app/controllers/admin/users/practice_progress_batches_controller.rb:19-21 (3)

Admin::Users::PracticeProgressController
  set_user                            app/controllers/admin/users/practice_progress_controller.rb:31-33 (3)
  show                                app/controllers/admin/users/practice_progress_controller.rb:6-10 (5)

Admin::UsersController
  edit                                app/controllers/admin/users_controller.rb:32-32 (1)
  set_user                            app/controllers/admin/users_controller.rb:59-61 (3)
  show                                app/controllers/admin/users_controller.rb:28-30 (3)

AffiliateKickbackJob
  perform                             app/jobs/affiliate_kickback_job.rb:10-22 (13)

Announcement
  ransackable_associations            app/models/announcement.rb:33-35 (3)
  ransackable_attributes              app/models/announcement.rb:29-31 (3)

AnnouncementsController
  edit                                app/controllers/announcements_controller.rb:46-46 (1)
  new                                 app/controllers/announcements_controller.rb:24-44 (21)
  rewrite_announcement                app/controllers/announcements_controller.rb:100-107 (8)
  set_announcement                    app/controllers/announcements_controller.rb:83-85 (3)
  show                                app/controllers/announcements_controller.rb:17-22 (6)

Answer
  ransackable_associations            app/models/answer.rb:23-25 (3)
  ransackable_attributes              app/models/answer.rb:19-21 (3)

ApplicationController
  allow_cross_domain_access           app/controllers/application_controller.rb:21-24 (4)
  basic_auth                          app/controllers/application_controller.rb:28-32 (5)
  init_user                           app/controllers/application_controller.rb:34-36 (3)
  require_card                        app/controllers/application_controller.rb:42-44 (3)
  require_scheduler_inheritation      app/controllers/application_controller.rb:50-52 (3)
  require_subscription                app/controllers/application_controller.rb:46-48 (3)
  save_affiliate_rd_code              app/controllers/application_controller.rb:58-67 (10)
  set_available_emojis                app/controllers/application_controller.rb:38-40 (3)
  set_current_user_practice           app/controllers/application_controller.rb:54-56 (3)

ApplicationHelper
  my_practice?                        app/helpers/application_helper.rb:4-8 (5)
  pair_work_available?                app/helpers/application_helper.rb:14-16 (3)
  pjord_ai_badge                      app/helpers/application_helper.rb:18-22 (5)

Article
  prepared_thumbnail_url              app/models/article.rb:61-67 (7)
  selected_thumbnail_url              app/models/article.rb:69-71 (3)
  set_published_at                    app/models/article.rb:101-103 (3)
  will_be_published?                  app/models/article.rb:97-99 (3)

ArticlesController
  edit                                app/controllers/articles_controller.rb:34-34 (1)
  list_articles                       app/controllers/articles_controller.rb:71-75 (5)
  list_recent_articles                app/controllers/articles_controller.rb:77-80 (4)
  new                                 app/controllers/articles_controller.rb:30-32 (3)
  set_article                         app/controllers/articles_controller.rb:67-69 (3)
  show                                app/controllers/articles_controller.rb:19-28 (10)

ArticlesHelper
  contributor                         app/helpers/articles_helper.rb:4-6 (3)
  feature_tag?                        app/helpers/articles_helper.rb:22-24 (3)
  meta_robots_tag                     app/helpers/articles_helper.rb:17-20 (4)
  ogp_image_url                       app/helpers/articles_helper.rb:12-15 (4)
  thumbnail_blank?                    app/helpers/articles_helper.rb:8-10 (3)

Authentication
  require_admin_login_for_api         app/controllers/concerns/authentication.rb:34-37 (4)
  require_admin_or_mentor_login_for_api app/controllers/concerns/authentication.rb:49-53 (5)
  require_login_for_api               app/controllers/concerns/authentication.rb:29-32 (4)
  require_mentor_login_for_api        app/controllers/concerns/authentication.rb:39-42 (4)
  require_staff_login_for_api         app/controllers/concerns/authentication.rb:44-47 (4)

Authentication::AccessRequirements
  require_active_user_login           app/controllers/concerns/authentication/access_requirements.rb:6-12 (7)
  require_admin_login                 app/controllers/concerns/authentication/access_requirements.rb:14-18 (5)
  require_admin_or_adviser_login      app/controllers/concerns/authentication/access_requirements.rb:46-50 (5)
  require_admin_or_mentor_login       app/controllers/concerns/authentication/access_requirements.rb:26-30 (5)
  require_mentor_login                app/controllers/concerns/authentication/access_requirements.rb:20-24 (5)
  require_staff_login                 app/controllers/concerns/authentication/access_requirements.rb:32-36 (5)
  require_trainee_login               app/controllers/concerns/authentication/access_requirements.rb:38-42 (5)

AuthoredBook
  sorted                              app/models/authored_book.rb:13 (1)

BookmarkDecorator
  reported_on_or_created_at           app/decorators/bookmark_decorator.rb:4-6 (3)

BooksController
  edit                                app/controllers/books_controller.rb:28-28 (1)
  new                                 app/controllers/books_controller.rb:15-17 (3)
  set_book                            app/controllers/books_controller.rb:55-57 (3)

Bootcamp::Setup
  attachment                          lib/bootcamp/setup.rb:10-18 (9)

BulkEmbeddingJob
  perform                             app/jobs/bulk_embedding_job.rb:6-15 (10)

Buzz
  url_format                          app/models/buzz.rb:11-17 (7)

BuzzesHelper
  group_buzzes_by_month               app/helpers/buzzes_helper.rb:4-6 (3)

Cache
  mentioned_and_unread_notification_count app/models/cache.rb:87-91 (5)
  mentioned_notification_count        app/models/cache.rb:77-81 (5)

Calendar::NicoNicoCalendarComponent
  current_calendar                    app/components/calendar/nico_nico_calendar_component.rb:35 (1)
  frame_and_background                app/components/calendar/nico_nico_calendar_component.rb:19-23 (5)
  next_month?                         app/components/calendar/nico_nico_calendar_component.rb:25-27 (3)
  next_month_path                     app/components/calendar/nico_nico_calendar_component.rb:29-31 (3)
  prev_month?                         app/components/calendar/nico_nico_calendar_component.rb:11-13 (3)
  prev_month_path                     app/components/calendar/nico_nico_calendar_component.rb:15-17 (3)

Campaign
  current_title                       app/models/campaign.rb:31-35 (5)
  example_end_at                      app/models/campaign.rb:45-47 (3)
  example_pay_at                      app/models/campaign.rb:49-51 (3)
  example_start_at                    app/models/campaign.rb:41-43 (3)
  user_trial_period                   app/models/campaign.rb:53-57 (5)

CodingTest
  no_test_cases                       app/models/coding_test.rb:30-34 (5)
  passed_by?                          app/models/coding_test.rb:24-26 (3)

CodingTestCase
  coding_test                         app/models/coding_test_case.rb:4 (1)

CodingTestSubmission
  coding_test                         app/models/coding_test_submission.rb:4 (1)

CodingTests::CodingTestSubmissionsController
  set_coding_test                     app/controllers/coding_tests/coding_test_submissions_controller.rb:20-22 (3)
  show                                app/controllers/coding_tests/coding_test_submissions_controller.rb:14-16 (3)

CodingTestsController
  show                                app/controllers/coding_tests_controller.rb:4-7 (4)

ColleagueTraineesRecentReportsQuery
  query                               app/queries/colleague_trainees_recent_reports_query.rb:8-15 (8)

ComebackController
  new                                 app/controllers/comeback_controller.rb:6-8 (3)

Comment
  params_for_keyword_search           app/models/comment.rb:41-44 (4)
  ransackable_associations            app/models/comment.rb:27-29 (3)
  ransackable_attributes              app/models/comment.rb:23-25 (3)

CommentHelper
  latest_comment?                     app/helpers/comment_helper.rb:4-6 (3)

CommentsHelper
  user_comments_page?                 app/helpers/comments_helper.rb:4-6 (3)

CompaniesController
  show                                app/controllers/companies_controller.rb:8-10 (3)

CompaniesHelper
  desc_ordered_companies_with_empty   app/helpers/companies_helper.rb:4-7 (4)

Company
  ransackable_associations            app/models/company.rb:27-29 (3)
  ransackable_attributes              app/models/company.rb:23-25 (3)

CompanyDecorator
  adviser_sign_up_url                 app/decorators/company_decorator.rb:8-14 (7)
  logo_image                          app/decorators/company_decorator.rb:4-6 (3)
  trainee_sign_up_url                 app/decorators/company_decorator.rb:16-22 (7)

CompletedLearningsQuery
  query                               app/queries/completed_learnings_query.rb:8-15 (8)

CopyCheck
  products_available?                 app/interactors/copy_check.rb:68-70 (3)

CorporateTrainingInquiriesController
  created                             app/controllers/corporate_training_inquiries_controller.rb:11-11 (1)
  new                                 app/controllers/corporate_training_inquiries_controller.rb:7-9 (3)

CorporateTrainingInquiry
  meeting_dates_not_in_past           app/models/corporate_training_inquiry.rb:32-36 (5)
  unique_meeting_dates                app/models/corporate_training_inquiry.rb:26-30 (5)

CoursesHelper
  find_course                         app/helpers/courses_helper.rb:4-6 (3)
  new_grant_course_user_url           app/helpers/courses_helper.rb:8-11 (4)

CurrentUser::BookmarksController
  dashboard                           app/controllers/current_user/bookmarks_controller.rb:10-19 (10)
  set_bookmarks                       app/controllers/current_user/bookmarks_controller.rb:28-30 (3)

CurrentUser::PasswordController
  edit                                app/controllers/current_user/password_controller.rb:6-6 (1)
  set_user                            app/controllers/current_user/password_controller.rb:25-27 (3)

CurrentUser::ProductsController
  set_products                        app/controllers/current_user/products_controller.rb:15-17 (3)
  set_user                            app/controllers/current_user/products_controller.rb:11-13 (3)

CurrentUser::ReportsController
  set_reports                         app/controllers/current_user/reports_controller.rb:17-19 (3)
  set_user                            app/controllers/current_user/reports_controller.rb:13-15 (3)

CurrentUser::WatchesController
  set_user                            app/controllers/current_user/watches_controller.rb:13-15 (3)
  set_watches                         app/controllers/current_user/watches_controller.rb:17-19 (3)

CurrentUserController
  edit                                app/controllers/current_user_controller.rb:6-8 (3)
  set_user                            app/controllers/current_user_controller.rb:42-44 (3)

DashboardBookmarkComponent
  reported_on_or_created_at           app/components/dashboard_bookmark_component.rb:22-24 (3)

DiscordAsyncAdapter
  enqueue                             app/models/discord_async_adapter.rb:8-11 (4)

DiscordJob
  perform                             app/jobs/discord_job.rb:6-8 (3)

DiscordProfile
  no_consecutive_periods              app/models/discord_profile.rb:35-39 (5)
  ransackable_attributes              app/models/discord_profile.rb:6-8 (3)
  validate_only_underscore_and_period app/models/discord_profile.rb:29-33 (5)

EmbeddingGenerateJob
  perform                             app/jobs/embedding_generate_job.rb:8-26 (19)

Event
  before_opening?                     app/models/event.rb:62-64 (3)
  closing?                            app/models/event.rb:66-68 (3)
  end_at_be_greater_than_start_at     app/models/event.rb:129-134 (6)
  first_come_first_served             app/models/event.rb:157-159 (3)
  open_end_at_be_greater_than_open_start_at app/models/event.rb:136-141 (6)
  open_end_at_be_less_than_end_at     app/models/event.rb:150-155 (6)
  open_start_at_be_less_than_start_at app/models/event.rb:143-148 (6)
  opening?                            app/models/event.rb:58-60 (3)
  ransackable_associations            app/models/event.rb:54-56 (3)
  ransackable_attributes              app/models/event.rb:50-52 (3)
  related_to                          app/models/event.rb:45 (1)

EventDecorator
  period                              app/decorators/event_decorator.rb:4-10 (7)

Events::ParticipationsController
  set_event                           app/controllers/events/participations_controller.rb:25-27 (3)

EventsController
  edit                                app/controllers/events_controller.rb:42-42 (1)
  new                                 app/controllers/events_controller.rb:20-26 (7)
  set_event                           app/controllers/events_controller.rb:78-80 (3)
  show                                app/controllers/events_controller.rb:13-18 (6)

EventsHelper
  event_comment_count                 app/helpers/events_helper.rb:16-28 (13)
  event_participant_count             app/helpers/events_helper.rb:30-32 (3)
  event_waitlist_count                app/helpers/events_helper.rb:34-36 (3)
  google_calendar_url                 app/helpers/events_helper.rb:4-14 (11)

FAQ
  faq_category                        app/models/faq.rb:7 (1)

FAQHelper
  format_question                     app/helpers/faq_helper.rb:4-6 (3)

Following
  followed                            app/models/following.rb:5 (1)
  follower                            app/models/following.rb:4 (1)

Footprint
  count_for_resource                  app/models/footprint.rb:17-19 (3)

Footprintable
  footprints                          app/models/concerns/footprintable.rb:7 (1)

GenerateMovieThumbnailJob
  perform                             app/jobs/generate_movie_thumbnail_job.rb:6-13 (8)

Generation
  count_classmates_by_target          app/models/generation.rb:48-50 (3)
  number                              app/models/generation.rb:19 (1)

GenerationsController
  show                                app/controllers/generations_controller.rb:7-10 (4)

GraduationController
  set_redirect_url                    app/controllers/graduation_controller.rb:25-27 (3)
  set_user                            app/controllers/graduation_controller.rb:21-23 (3)

GrantCourseApplicationDecorator
  address                             app/decorators/grant_course_application_decorator.rb:12-15 (4)
  sender_name_and_email               app/decorators/grant_course_application_decorator.rb:21-23 (3)
  tel                                 app/decorators/grant_course_application_decorator.rb:17-19 (3)

GrantCourseApplicationsController
  created                             app/controllers/grant_course_applications_controller.rb:22-22 (1)
  new                                 app/controllers/grant_course_applications_controller.rb:6-8 (3)

Grass::GrassComponent
  next_year?                          app/components/grass/grass_component.rb:11-13 (3)
  next_year_path                      app/components/grass/grass_component.rb:19-21 (3)
  prev_year_path                      app/components/grass/grass_component.rb:15-17 (3)

GrassLearningTimeQuery
  query                               app/queries/grass_learning_time_query.rb:15-19 (5)

HibernationController
  new                                 app/controllers/hibernation_controller.rb:8-11 (4)
  show                                app/controllers/hibernation_controller.rb:6-6 (1)

HomeController
  pricing                             app/controllers/home_controller.rb:22-22 (1)

HomeHelper
  anchor_to_required_field            app/helpers/home_helper.rb:4-13 (10)

Image
  strip_exif                          app/models/image.rb:11-25 (15)

InquiriesController
  created                             app/controllers/inquiries_controller.rb:11-11 (1)
  new                                 app/controllers/inquiries_controller.rb:7-9 (3)

Inquiry
  completed_by_user                   app/models/inquiry.rb:6 (1)

InquiryDecorator
  sender_name_and_email               app/decorators/inquiry_decorator.rb:4-6 (3)

LabelHelper
  bookmarkable_label                  app/helpers/label_helper.rb:4-13 (10)

LayoutHelper
  display_footer?                     app/helpers/layout_helper.rb:12-14 (3)
  display_forms?                      app/helpers/layout_helper.rb:16-18 (3)
  display_global_nav?                 app/helpers/layout_helper.rb:8-10 (3)
  display_header?                     app/helpers/layout_helper.rb:4-6 (3)

LearningDecorator
  completion_modal?                   app/decorators/learning_decorator.rb:4-6 (3)

LearningTime
  learning_times_finished_at_be_greater_than_started_at app/models/learning_time.rb:13-17 (5)

LearningTimeFrame
  learning_time_frames_users          app/models/learning_time_frame.rb:6 (1)

LearningTimeFramesUser
  learning_time_frame                 app/models/learning_time_frames_user.rb:5 (1)

Learnings::LearningComponent
  product_label                       app/components/learnings/learning_component.rb:19-21 (3)
  product_link                        app/components/learnings/learning_component.rb:15-17 (3)
  submission?                         app/components/learnings/learning_component.rb:23-25 (3)

MarkdownHelper
  md_summary                          app/helpers/markdown_helper.rb:19-22 (4)
  process_markdown_case               app/helpers/markdown_helper.rb:35-44 (10)

MarkdownProhibitedValidator
  validate_each                       app/validators/markdown_prohibited_validator.rb:4-9 (6)

Mentioner
  after_save_mention                  app/models/concerns/mentioner.rb:4-11 (8)

Mentor::BuzzesController
  edit                                app/controllers/mentor/buzzes_controller.rb:16-16 (1)
  new                                 app/controllers/mentor/buzzes_controller.rb:12-14 (3)
  set_buzz                            app/controllers/mentor/buzzes_controller.rb:54-56 (3)

Mentor::CategoriesController
  edit                                app/controllers/mentor/categories_controller.rb:16-16 (1)
  new                                 app/controllers/mentor/categories_controller.rb:12-14 (3)
  set_category                        app/controllers/mentor/categories_controller.rb:43-45 (3)
  show                                app/controllers/mentor/categories_controller.rb:10-10 (1)

Mentor::CodingTestsController
  edit                                app/controllers/mentor/coding_tests_controller.rb:20-20 (1)
  new                                 app/controllers/mentor/coding_tests_controller.rb:16-18 (3)
  set_coding_test                     app/controllers/mentor/coding_tests_controller.rb:57-59 (3)

Mentor::CoursesController
  edit                                app/controllers/mentor/courses_controller.rb:19-19 (1)
  new                                 app/controllers/mentor/courses_controller.rb:10-17 (8)
  set_course                          app/controllers/mentor/courses_controller.rb:40-42 (3)

Mentor::Practices::SubmissionAnswerController
  edit                                app/controllers/mentor/practices/submission_answer_controller.rb:12-14 (3)
  new                                 app/controllers/mentor/practices/submission_answer_controller.rb:7-10 (4)
  set_submission_answer               app/controllers/mentor/practices/submission_answer_controller.rb:37-39 (3)

Mentor::PracticesController
  edit                                app/controllers/mentor/practices_controller.rb:17-17 (1)
  new                                 app/controllers/mentor/practices_controller.rb:13-15 (3)
  set_course                          app/controllers/mentor/practices_controller.rb:72-74 (3)
  set_practice                        app/controllers/mentor/practices_controller.rb:68-70 (3)

Mentor::SurveyQuestionsController
  edit                                app/controllers/mentor/survey_questions_controller.rb:31-31 (1)
  new                                 app/controllers/mentor/survey_questions_controller.rb:11-18 (8)
  set_survey_question                 app/controllers/mentor/survey_questions_controller.rb:43-45 (3)

Mentor::Surveys::SurveyAnswersController
  set_survey                          app/controllers/mentor/surveys/survey_answers_controller.rb:17-19 (3)
  show                                app/controllers/mentor/surveys/survey_answers_controller.rb:11-13 (3)

Mentor::Surveys::SurveyQuestionListingsController
  set_survey                          app/controllers/mentor/surveys/survey_question_listings_controller.rb:13-15 (3)

Mentor::Surveys::SurveyResultController
  set_survey                          app/controllers/mentor/surveys/survey_result_controller.rb:20-22 (3)
  show                                app/controllers/mentor/surveys/survey_result_controller.rb:7-16 (10)

Mentor::SurveysController
  edit                                app/controllers/mentor/surveys_controller.rb:29-29 (1)
  new                                 app/controllers/mentor/surveys_controller.rb:21-27 (7)
  set_survey                          app/controllers/mentor/surveys_controller.rb:56-58 (3)
  show                                app/controllers/mentor/surveys_controller.rb:11-19 (9)

MetaTagsHelper
  welcome_meta_tags                   app/helpers/meta_tags_helper.rb:31-44 (14)

MicroReport
  set_default_comment_user            app/models/micro_report.rb:40-42 (3)

Movie
  generate_default_thumbnail          app/models/movie.rb:59-64 (6)
  practices_movies                    app/models/movie.rb:15 (1)
  ransackable_associations            app/models/movie.rb:38-40 (3)
  ransackable_attributes              app/models/movie.rb:34-36 (3)
  start_transcode_job                 app/models/movie.rb:52-57 (6)

MoviesController
  edit                                app/controllers/movies_controller.rb:30-30 (1)
  new                                 app/controllers/movies_controller.rb:26-28 (3)
  set_categories                      app/controllers/movies_controller.rb:63-69 (7)
  set_movie                           app/controllers/movies_controller.rb:97-99 (3)
  show                                app/controllers/movies_controller.rb:22-24 (3)

NavigationHelper
  current_link                        app/helpers/navigation_helper.rb:4-8 (5)

NicoNicoCalendar
  with_reports                        app/models/nico_nico_calendar.rb:18-23 (6)

Notification::RedirectorController
  set_my_notification                 app/controllers/notification/redirector_controller.rb:18-23 (6)
  show                                app/controllers/notification/redirector_controller.rb:6-14 (9)

NotificationMailer
  create_page                         app/mailers/notification_mailer.rb:59-64 (6)
  mentioned                           app/mailers/notification_mailer.rb:26-31 (6)

NotificationsController
  set_my_notification                 app/controllers/notifications_controller.rb:24-26 (3)
  show                                app/controllers/notifications_controller.rb:15-20 (6)

NotificationsHelper
  ensure_notifications?               app/helpers/notifications_helper.rb:4-6 (3)

OrderedCategoriesFromPracticesQuery
  query                               app/queries/ordered_categories_from_practices_query.rb:8-16 (9)

Page
  empty_slug_to_nil                   app/models/page.rb:45-47 (3)
  last_updated_user                   app/models/page.rb:14 (1)
  ransackable_associations            app/models/page.rb:30-32 (3)
  ransackable_attributes              app/models/page.rb:26-28 (3)

PageTabComponent
  badge                               app/components/page_tab_component.rb:15 (1)

PageTabs::CompaniesHelper
  company_page_tabs                   app/helpers/page_tabs/companies_helper.rb:5-12 (8)

PageTabs::CoursesHelper
  courses_page_tabs                   app/helpers/page_tabs/courses_helper.rb:5-10 (6)

PageTabs::DashboardHelper
  dashboard_page_tabs                 app/helpers/page_tabs/dashboard_helper.rb:5-18 (14)

PageTabs::EventsHelper
  events_page_tabs                    app/helpers/page_tabs/events_helper.rb:5-10 (6)

PageTabs::NotificationsHelper
  notifications_page_tabs             app/helpers/page_tabs/notifications_helper.rb:5-17 (13)

PageTabs::PracticesHelper
  practice_page_tabs                  app/helpers/page_tabs/practices_helper.rb:5-18 (14)

PageTabs::ProductsHelper
  products_page_tabs                  app/helpers/page_tabs/products_helper.rb:5-16 (12)

PageTabs::QuestionsAndPairWorksHelper
  questions_and_pair_works_page_tabs  app/helpers/page_tabs/questions_and_pair_works_helper.rb:5-10 (6)

PageTabs::ReportsHelper
  report_page_tabs                    app/helpers/page_tabs/reports_helper.rb:5-10 (6)

PageTabs::TalksHelper
  talks_page_tabs                     app/helpers/page_tabs/talks_helper.rb:5-11 (7)

PageTabs::UsersHelper
  user_page_tabs                      app/helpers/page_tabs/users_helper.rb:5-24 (20)
  users_page_tabs                     app/helpers/page_tabs/users_helper.rb:26-37 (12)

PagesController
  edit                                app/controllers/pages_controller.rb:38-38 (1)
  new                                 app/controllers/pages_controller.rb:34-36 (3)
  redirect_to_slug                    app/controllers/pages_controller.rb:115-119 (5)
  set_categories                      app/controllers/pages_controller.rb:107-113 (7)
  set_page                            app/controllers/pages_controller.rb:87-89 (3)
  show                                app/controllers/pages_controller.rb:23-32 (10)

PairWork
  find_scheduled_at                   app/models/pair_work.rb:117-119 (3)
  ransackable_associations            app/models/pair_work.rb:62-64 (3)
  ransackable_attributes              app/models/pair_work.rb:58-60 (3)
  reserved_at_in_schedules            app/models/pair_work.rb:131-133 (3)
  set_published_at                    app/models/pair_work.rb:127-129 (3)
  will_be_published?                  app/models/pair_work.rb:123-125 (3)

PairWorkDecorator
  important?                          app/decorators/pair_work_decorator.rb:4-6 (3)

PairWorksController
  edit                                app/controllers/pair_works_controller.rb:23-23 (1)
  new                                 app/controllers/pair_works_controller.rb:25-27 (3)
  set_my_pair_work                    app/controllers/pair_works_controller.rb:63-65 (3)
  show                                app/controllers/pair_works_controller.rb:18-21 (4)

PairWorksHelper
  learning_time_frame_checked?        app/helpers/pair_works_helper.rb:28-30 (3)
  meta_label_by_status                app/helpers/pair_works_helper.rb:44-47 (4)
  schedule_check_box_id               app/helpers/pair_works_helper.rb:40-42 (3)
  schedule_dates                      app/helpers/pair_works_helper.rb:4-6 (3)
  schedule_target_time                app/helpers/pair_works_helper.rb:32-38 (7)
  sorted_wdays                        app/helpers/pair_works_helper.rb:8-17 (10)

Paper::CourseDocumentsController
  show                                app/controllers/paper/course_documents_controller.rb:9-19 (11)

Paper::ExerciseProcedureDocumentsController
  show                                app/controllers/paper/exercise_procedure_documents_controller.rb:5-8 (4)

Partial::GitHubGrassController
  show                                app/controllers/partial/git_hub_grass_controller.rb:4-6 (3)

PasswordResetsController
  edit                                app/controllers/password_resets_controller.rb:16-23 (8)

Pjord::Agent
  SYSTEM_PROMPT                       app/agents/pjord/agent.rb:4 (1)

Pjord::MentionResponseAgent
  practice_title                      app/agents/pjord/mention_response_agent.rb:10-23 (14)

PjordProductReviewJob
  perform                             app/jobs/pjord_product_review_job.rb:8-19 (12)

PjordQuestionAnswerJob
  perform                             app/jobs/pjord_question_answer_job.rb:7-24 (18)

PjordReportCommentJob
  perform                             app/jobs/pjord_report_comment_job.rb:7-23 (17)

PjordRespondJob
  perform                             app/jobs/pjord_respond_job.rb:8-24 (17)

PostAnnouncementJob
  perform                             app/jobs/post_announcement_job.rb:6-11 (6)

Practice
  all_text                            app/models/practice.rb:138-140 (3)
  completed_learnings                 app/models/practice.rb:9 (1)
  convert_to_hour_minute              app/models/practice.rb:239-247 (9)
  exists_learning?                    app/models/practice.rb:127-132 (6)
  last_updated_user                   app/models/practice.rb:36 (1)
  practices_movies                    app/models/practice.rb:33 (1)
  ransackable_associations            app/models/practice.rb:83-85 (3)
  ransackable_attributes              app/models/practice.rb:79-81 (3)
  skipped_users                       app/models/practice.rb:23 (1)
  source_id_cannot_be_self            app/models/practice.rb:249-253 (5)
  source_practice                     app/models/practice.rb:56 (1)
  started_or_submitted_learnings      app/models/practice.rb:14 (1)

PracticeContentToggle::PracticeContentToggleComponent
  practice_content                    app/components/practice_content_toggle/practice_content_toggle_component.rb:10-25 (16)

PracticeDecorator
  submission_answer_button?           app/decorators/practice_decorator.rb:4-6 (3)

PracticeProgressPresenter
  copied_practice_for                 app/presenters/practice_progress_presenter.rb:79-86 (8)
  copied_practice_learning_for        app/presenters/practice_progress_presenter.rb:100 (1)
  copied_practice_learnings_for       app/presenters/practice_progress_presenter.rb:42-45 (4)
  copied_practice_product_for         app/presenters/practice_progress_presenter.rb:101 (1)
  copied_practice_products_for        app/presenters/practice_progress_presenter.rb:47-50 (4)
  copy_destination_practice_for       app/presenters/practice_progress_presenter.rb:107-109 (3)
  migration_candidates?               app/presenters/practice_progress_presenter.rb:61-63 (3)
  migration_progress_percentage       app/presenters/practice_progress_presenter.rb:54-59 (6)
  practice_status_for                 app/presenters/practice_progress_presenter.rb:65-70 (6)
  product_for                         app/presenters/practice_progress_presenter.rb:72-77 (6)
  user_products_for                   app/presenters/practice_progress_presenter.rb:32-35 (4)

Practices::CompletionController
  show                                app/controllers/practices/completion_controller.rb:7-9 (3)

Practices::SubmissionAnswerController
  check_permission!                   app/controllers/practices/submission_answer_controller.rb:14-20 (7)
  show                                app/controllers/practices/submission_answer_controller.rb:6-10 (5)

PracticesController
  set_practice                        app/controllers/practices_controller.rb:23-25 (3)
  show                                app/controllers/practices_controller.rb:7-19 (13)

PracticesHelper
  all_books                           app/helpers/practices_helper.rb:6-8 (3)
  practice_ogp_image_tag              app/helpers/practices_helper.rb:14-16 (3)
  practice_ogp_image_url              app/helpers/practices_helper.rb:18-20 (3)
  practice_ogp_meta_tags              app/helpers/practices_helper.rb:22-27 (6)

PracticesMovie
  movie                               app/models/practices_movie.rb:5 (1)

ProcedureHelper
  procedure                           app/helpers/procedure_helper.rb:4-8 (5)

Product
  add_latest_commented_at             app/models/product.rb:69-75 (7)
  ids_of_common_checked_with          app/models/product.rb:36 (1)
  last_commented_user                 app/models/product.rb:121-125 (5)
  ransackable_associations            app/models/product.rb:65-67 (3)
  ransackable_attributes              app/models/product.rb:61-63 (3)
  self_assigned_and_replied_products  app/models/product.rb:42 (1)

ProductDecorator
  after_submission_message?           app/decorators/product_decorator.rb:11-16 (6)
  goal_content_toggle_component       app/decorators/product_decorator.rb:29-34 (6)
  list_title                          app/decorators/product_decorator.rb:50-57 (8)
  meta_description                    app/decorators/product_decorator.rb:6-9 (4)
  practice_content_toggle_component   app/decorators/product_decorator.rb:22-27 (6)
  skipped_practice_link               app/decorators/product_decorator.rb:36-48 (13)
  user_course_practice                app/decorators/product_decorator.rb:18-20 (3)

ProductSelfAssignedNoRepliedQuery
  query                               app/queries/product_self_assigned_no_replied_query.rb:13-18 (6)

Products::CheckerAssignmentsController
  validate_assignment                 app/controllers/products/checker_assignments_controller.rb:34-38 (5)
  validate_removal                    app/controllers/products/checker_assignments_controller.rb:40-44 (5)

Products::ProductComponent
  joining_status_class                app/components/products/product_component.rb:22-24 (3)
  last_checked_at                     app/components/products/product_component.rb:45-47 (3)
  last_checked_user_login_name        app/components/products/product_component.rb:49-51 (3)
  not_responded_sign?                 app/components/products/product_component.rb:30-34 (5)
  practice_title                      app/components/products/product_component.rb:26-28 (3)
  role_class                          app/components/products/product_component.rb:14-16 (3)
  role_class_for_user                 app/components/products/product_component.rb:18-20 (3)
  until_next_elapsed_days             app/components/products/product_component.rb:36-38 (3)

Products::UnassignedProductsComponent
  any_products_elapsed_reply_warning_days? app/components/products/unassigned_products_component.rb:15-17 (3)
  count_almost_passed_reply_warning_days app/components/products/unassigned_products_component.rb:50-56 (7)
  count_products_grouped_by           app/components/products/unassigned_products_component.rb:19-21 (3)
  elapsed_days_class                  app/components/products/unassigned_products_component.rb:23-34 (12)
  elapsed_days_id                     app/components/products/unassigned_products_component.rb:46-48 (3)
  elapsed_days_text                   app/components/products/unassigned_products_component.rb:36-44 (9)
  filtered_products_grouped_by_elapsed_days app/components/products/unassigned_products_component.rb:58-64 (7)

Products::UserProductsComponent
  product_component_params            app/components/products/user_products_component.rb:20-30 (11)
  products?                           app/components/products/user_products_component.rb:16-18 (3)

ProductsController
  check_permission!                   app/controllers/products_controller.rb:132-136 (5)
  edit                                app/controllers/products_controller.rb:42-45 (4)
  new                                 app/controllers/products_controller.rb:37-40 (4)
  review_by_pjord                     app/controllers/products_controller.rb:88-98 (11)
  set_target                          app/controllers/products_controller.rb:178-180 (3)
  set_watch                           app/controllers/products_controller.rb:144-146 (3)
  show                                app/controllers/products_controller.rb:17-35 (19)

ProductsHelper
  elapsed_days_label                  app/helpers/products_helper.rb:61-69 (9)
  elapsed_days_nav_item_class         app/helpers/products_helper.rb:97-107 (11)
  filter_button_class                 app/helpers/products_helper.rb:71-79 (9)
  filter_button_label                 app/helpers/products_helper.rb:93-95 (3)
  filter_button_url                   app/helpers/products_helper.rb:81-91 (11)
  last_commented_time_label           app/helpers/products_helper.rb:44-53 (10)
  not_responded_sign?                 app/helpers/products_helper.rb:23-29 (7)
  product_category_practices_link_path app/helpers/products_helper.rb:4-9 (6)
  unconfirmed_links_label             app/helpers/products_helper.rb:11-21 (11)
  until_next_elapsed_days             app/helpers/products_helper.rb:31-42 (12)

Question
  ransackable_associations            app/models/question.rb:56-58 (3)
  ransackable_attributes              app/models/question.rb:52-54 (3)
  set_published_at                    app/models/question.rb:120-122 (3)
  will_be_published?                  app/models/question.rb:116-118 (3)

QuestionsController
  edit                                app/controllers/questions_controller.rb:53-53 (1)
  new                                 app/controllers/questions_controller.rb:49-51 (3)
  set_categories                      app/controllers/questions_controller.rb:92-98 (7)
  set_editable_question               app/controllers/questions_controller.rb:88-90 (3)
  set_question                        app/controllers/questions_controller.rb:84-86 (3)
  set_watch                           app/controllers/questions_controller.rb:104-106 (3)
  show                                app/controllers/questions_controller.rb:28-47 (20)

Reaction
  reactionable                        app/models/reaction.rb:22 (1)

Reactions::ReactionsComponent
  reaction_attribute                  app/components/reactions/reactions_component.rb:35-37 (3)
  reactions_attributes                app/components/reactions/reactions_component.rb:9-18 (10)

ReactionsHelper
  reaction_attributes_all             app/helpers/reactions_helper.rb:30-32 (3)
  reactions_attributes                app/helpers/reactions_helper.rb:4-13 (10)

RegularEvent
  DAYS_OF_THE_WEEK_COUNT              app/models/regular_event.rb:6 (1)
  end_at_be_greater_than_start_at     app/models/regular_event.rb:213-218 (6)
  end_on=                             app/models/regular_event.rb:4 (1)
  participated_by                     app/models/regular_event.rb:54 (1)
  ransackable_associations            app/models/regular_event.rb:91-93 (3)
  ransackable_attributes              app/models/regular_event.rb:87-89 (3)
  start_on=                           app/models/regular_event.rb:4 (1)
  validate_skip_on_uniqueness         app/models/regular_event.rb:230-238 (9)

RegularEventDecorator
  next_holding_date                   app/decorators/regular_event_decorator.rb:12-26 (15)
  out_of_repeat_rule_skip_dates       app/decorators/regular_event_decorator.rb:36-38 (3)
  upcoming_excluded_dates             app/decorators/regular_event_decorator.rb:28-34 (7)

RegularEvents::ParticipationsController
  set_regular_event                   app/controllers/regular_events/participations_controller.rb:25-27 (3)

RegularEventsController
  edit                                app/controllers/regular_events_controller.rb:45-45 (1)
  new                                 app/controllers/regular_events_controller.rb:21-28 (8)
  set_regular_event                   app/controllers/regular_events_controller.rb:66-68 (3)
  show                                app/controllers/regular_events_controller.rb:14-19 (6)

Report
  faces                               app/models/report.rb:77-82 (6)
  interval                            app/models/report.rb:139-141 (3)
  latest_of_user?                     app/models/report.rb:132-137 (6)
  limited_date_within_range           app/models/report.rb:160-165 (6)
  next                                app/models/report.rb:102-107 (6)
  ransackable_associations            app/models/report.rb:72-74 (3)
  ransackable_attributes              app/models/report.rb:68-70 (3)
  set_default_emotion                 app/models/report.rb:124-126 (3)
  total_learning_time                 app/models/report.rb:128-130 (3)

ReportDecorator
  number                              app/decorators/report_decorator.rb:4-6 (3)

Reports::UncheckedController
  require_admin_or_mentor!            app/controllers/reports/unchecked_controller.rb:15-17 (3)

ReportsController
  comment_by_pjord                    app/controllers/reports_controller.rb:93-103 (11)
  edit                                app/controllers/reports_controller.rb:52-54 (3)
  new                                 app/controllers/reports_controller.rb:34-50 (17)
  set_categories                      app/controllers/reports_controller.rb:147-149 (3)
  set_check                           app/controllers/reports_controller.rb:135-137 (3)
  set_checks                          app/controllers/reports_controller.rb:143-145 (3)
  set_editable_report                 app/controllers/reports_controller.rb:127-129 (3)
  set_my_report                       app/controllers/reports_controller.rb:123-125 (3)
  set_report                          app/controllers/reports_controller.rb:119-121 (3)
  set_user                            app/controllers/reports_controller.rb:131-133 (3)
  set_watch                           app/controllers/reports_controller.rb:177-179 (3)
  show                                app/controllers/reports_controller.rb:22-32 (11)

ReportsHelper
  category_practices                  app/helpers/reports_helper.rb:33-35 (3)
  convert_to_ceiled_hour              app/helpers/reports_helper.rb:28-31 (4)
  convert_to_hour_minute              app/helpers/reports_helper.rb:17-26 (10)
  practice_options                    app/helpers/reports_helper.rb:4-10 (7)
  practice_options_within_course      app/helpers/reports_helper.rb:12-15 (4)

RequestRetirement
  target_user                         app/models/request_retirement.rb:5 (1)

RequestRetirementsController
  deny_not_requester                  app/controllers/request_retirements_controller.rb:39-43 (5)
  new                                 app/controllers/request_retirements_controller.rb:7-9 (3)
  set_request_retirement              app/controllers/request_retirements_controller.rb:28-30 (3)
  show                                app/controllers/request_retirements_controller.rb:11-11 (1)

RetirementController
  new                                 app/controllers/retirement_controller.rb:8-10 (3)
  show                                app/controllers/retirement_controller.rb:6-6 (1)

Scheduler::Daily::AutoCloseQuestionsController
  show                                app/controllers/scheduler/daily/auto_close_questions_controller.rb:4-9 (6)

Scheduler::Daily::AutoRetireController
  show                                app/controllers/scheduler/daily/auto_retire_controller.rb:4-7 (4)

Scheduler::Daily::FetchExternalEntryController
  show                                app/controllers/scheduler/daily/fetch_external_entry_controller.rb:4-7 (4)

Scheduler::Daily::NotifyCertainPeriodPassedAfterLastAnswerController
  show                                app/controllers/scheduler/daily/notify_certain_period_passed_after_last_answer_controller.rb:4-7 (4)

Scheduler::Daily::NotifyComingSoonRegularEventsController
  show                                app/controllers/scheduler/daily/notify_coming_soon_regular_events_controller.rb:4-7 (4)

Scheduler::Daily::NotifyProductReviewNotCompletedController
  show                                app/controllers/scheduler/daily/notify_product_review_not_completed_controller.rb:4-7 (4)

Scheduler::Daily::SendMailToHibernationUserController
  show                                app/controllers/scheduler/daily/send_mail_to_hibernation_user_controller.rb:4-7 (4)

Scheduler::Daily::SendMessageController
  show                                app/controllers/scheduler/daily/send_message_controller.rb:4-8 (5)

Scheduler::LinkCheckerController
  show                                app/controllers/scheduler/link_checker_controller.rb:4-12 (9)

Scheduler::StatisticController
  show                                app/controllers/scheduler/statistic_controller.rb:4-7 (4)

Scheduler::ValidatorController
  show                                app/controllers/scheduler/validator_controller.rb:4-21 (18)

SchedulerController
  require_token                       app/controllers/scheduler_controller.rb:10-14 (5)

SearchHelper
  formatted_search_summary            app/helpers/search_helper.rb:48-51 (4)

Searchable
  REQUIRED_SEARCH_METHODS             app/models/concerns/searchable.rb:6 (1)
  schedule_embedding_generation       app/models/concerns/searchable.rb:115-117 (3)
  search_thumbnail                    app/models/concerns/searchable.rb:31-35 (5)
  should_generate_embedding?          app/models/concerns/searchable.rb:119-123 (5)

SearchableComponent
  answer_meta_info                    app/components/searchable_component.rb:29-37 (9)
  comment_meta_info                   app/components/searchable_component.rb:19-27 (9)
  search_title_text                   app/components/searchable_component.rb:39-41 (3)
  word                                app/components/searchable_component.rb:45 (1)

SearchablesComponent
  searchables                         app/components/searchables_component.rb:13 (1)
  word                                app/components/searchables_component.rb:13 (1)

Searcher
  MODES_FOR_SELECT                    app/models/searcher.rb:5 (1)

Searcher::Configuration
  available_types_for_select          app/models/searcher/configuration.rb:98-104 (7)

Searcher::QueryBuilder
  reset_pg_bigm_cache!                app/models/searcher/query_builder.rb:32-34 (3)

SkippedPracticeComponent
  skipped_practices_count             app/components/skipped_practice_component.rb:11-18 (8)

SmartSearch::Configuration
  EMBEDDING_DIMENSION                 app/models/smart_search/configuration.rb:5 (1)

StaticPagesController
  campaign_basic                      app/controllers/static_pages_controller.rb:8-8 (1)

StudyStreak::StudyStreakTrackerComponent
  current_streak?                     app/components/study_streak/study_streak_tracker_component.rb:9-11 (3)
  current_streak_days                 app/components/study_streak/study_streak_tracker_component.rb:17-19 (3)
  current_streak_period               app/components/study_streak/study_streak_tracker_component.rb:25-31 (7)
  longest_streak?                     app/components/study_streak/study_streak_tracker_component.rb:13-15 (3)
  longest_streak_days                 app/components/study_streak/study_streak_tracker_component.rb:21-23 (3)
  longest_streak_period               app/components/study_streak/study_streak_tracker_component.rb:33-39 (7)
  target_user                         app/components/study_streak/study_streak_tracker_component.rb:43 (1)

SubTabComponent
  badge                               app/components/sub_tab_component.rb:14 (1)

SubTabs::PairWorksHelper
  pair_works_sub_tabs                 app/helpers/sub_tabs/pair_works_helper.rb:5-11 (7)

SubTabs::QuestionsHelper
  questions_sub_tabs                  app/helpers/sub_tabs/questions_helper.rb:5-12 (8)

SubTabs::SurveysHelper
  mentor_surveys_sub_tabs             app/helpers/sub_tabs/surveys_helper.rb:5-10 (6)

Subscription
  STATUS_CLASS_MAP                    app/models/subscription.rb:4 (1)

Survey
  answer_accepting?                   app/models/survey.rb:20-22 (3)
  answers?                            app/models/survey.rb:28-30 (3)

SurveyAnswer
  survey                              app/models/survey_answer.rb:4 (1)

SurveyQuestion
  answer_required_choice_exists?      app/models/survey_question.rb:28-38 (11)
  surveys                             app/models/survey_question.rb:15 (1)

SurveyQuestionAnswer
  reason_required?                    app/models/survey_question_answer.rb:12-23 (12)
  survey_answer                       app/models/survey_question_answer.rb:4 (1)

SurveyQuestionListing
  survey                              app/models/survey_question_listing.rb:5 (1)

Surveys::SurveyAnswersController
  check_already_answered              app/controllers/surveys/survey_answers_controller.rb:41-45 (5)
  check_survey_period                 app/controllers/surveys/survey_answers_controller.rb:33-39 (7)
  set_survey                          app/controllers/surveys/survey_answers_controller.rb:29-31 (3)

SurveysController
  check_already_answered              app/controllers/surveys_controller.rb:33-37 (5)
  check_survey_period                 app/controllers/surveys_controller.rb:25-31 (7)
  set_survey                          app/controllers/surveys_controller.rb:21-23 (3)
  show                                app/controllers/surveys_controller.rb:9-17 (9)

SurveysHelper
  question_options_within_survey_question app/helpers/surveys_helper.rb:4-9 (6)

Tag::EditComponent
  tag_id                              app/components/tag/edit_component.rb:4 (1)
  tag_name                            app/components/tag/edit_component.rb:4 (1)

Tag::FormComponent
  editable?                           app/components/tag/form_component.rb:23-25 (3)
  initial_tags                        app/components/tag/form_component.rb:11-13 (3)
  input_id                            app/components/tag/form_component.rb:29 (1)
  param_name                          app/components/tag/form_component.rb:29 (1)
  taggable_id                         app/components/tag/form_component.rb:19-21 (3)

Taggable
  contains_one_dot_only               app/models/concerns/taggable.rb:22-26 (5)
  contains_space                      app/models/concerns/taggable.rb:12-16 (5)

TalksController
  allow_show_talk_page_only_admin     app/controllers/talks_controller.rb:39-43 (5)
  set_members                         app/controllers/talks_controller.rb:53-57 (5)
  set_talk                            app/controllers/talks_controller.rb:45-47 (3)
  set_user                            app/controllers/talks_controller.rb:49-51 (3)
  show                                app/controllers/talks_controller.rb:32-35 (4)

TalksHelper
  action_uncompleted_index_path       app/helpers/talks_helper.rb:4-6 (3)

TestAuthentication
  test_login                          app/controllers/concerns/test_authentication.rb:6-8 (3)

TimeHelper
  minute_to_span                      app/helpers/time_helper.rb:4-13 (10)

TimeRangeHelper
  time_range                          app/helpers/time_range_helper.rb:4-9 (6)

TrainingCompletionController
  new                                 app/controllers/training_completion_controller.rb:9-11 (3)
  show                                app/controllers/training_completion_controller.rb:7-7 (1)

TranscodeJob
  perform                             app/jobs/transcode_job.rb:9-15 (7)

Transcoder::Client
  service_name                        app/models/transcoder/client.rb:95-97 (3)

UncheckedNoRepliedProductsQuery
  query                               app/queries/unchecked_no_replied_products_query.rb:8-25 (18)

UpcomingEvent
  event_type                          app/models/upcoming_event.rb:4 (1)
  for_job_hunting?                    app/models/upcoming_event.rb:34-38 (5)
  held_on_scheduled_date?             app/models/upcoming_event.rb:20-24 (5)
  scheduled_date                      app/models/upcoming_event.rb:4 (1)

UpcomingEventDecorator
  inner_title                         app/decorators/upcoming_event_decorator.rb:22-29 (8)
  inner_title_style                   app/decorators/upcoming_event_decorator.rb:13-20 (8)
  label_style                         app/decorators/upcoming_event_decorator.rb:4-11 (8)

UpcomingEventsGroup
  date_key                            app/models/upcoming_events_group.rb:4 (1)

User
  INVITATION_ROLES                    app/models/user.rb:32 (1)
  active_learnings                    app/models/user.rb:157 (1)
  adviser_or_mentor?                  app/models/user.rb:675-677 (3)
  articles                            app/models/user.rb:112 (1)
  authored_books                      app/models/user.rb:117 (1)
  away?                               app/models/user.rb:587-589 (3)
  belongs_company_and_adviser?        app/models/user.rb:815-817 (3)
  campaign                            app/models/user.rb:481 (1)
  checked_product_of?                 app/models/user.rb:595-597 (3)
  completed_learnings                 app/models/user.rb:146 (1)
  convert_blank_of_address_to_nil     app/models/user.rb:992-995 (4)
  depressed_reports                   app/models/user.rb:539-548 (10)
  external_entries                    app/models/user.rb:121 (1)
  footprints                          app/models/user.rb:99 (1)
  images                              app/models/user.rb:100 (1)
  in_school                           app/models/user.rb:325 (1)
  inactive                            app/models/user.rb:379 (1)
  learning_time_frames_users          app/models/user.rb:133 (1)
  not_advisers                        app/models/user.rb:334 (1)
  oauth_access_grants                 app/models/user.rb:207 (1)
  oauth_access_tokens                 app/models/user.rb:212 (1)
  participating?                      app/models/user.rb:744-747 (4)
  passive_relationships               app/models/user.rb:184 (1)
  password_required?                  app/models/user.rb:971-973 (3)
  practices_include_progress          app/models/user.rb:975-977 (3)
  profile_image_url                   app/models/user.rb:729-738 (10)
  ransackable_associations            app/models/user.rb:956-958 (3)
  ransackable_attributes              app/models/user.rb:941-950 (10)
  ransackable_scopes                  app/models/user.rb:952-954 (3)
  regular_events                      app/models/user.rb:114 (1)
  request_retirements                 app/models/user.rb:129 (1)
  required_practices_size_with_skip   app/models/user.rb:988-990 (3)
  retired_students                    app/models/user.rb:366 (1)
  role_for_thanks_page                app/models/user.rb:1023-1029 (7)
  send_notifications                  app/models/user.rb:140 (1)
  staff_or_paid?                      app/models/user.rb:667-669 (3)
  student_or_trainee_or_retired?      app/models/user.rb:712-714 (3)
  submitted?                          app/models/user.rb:583-585 (3)
  subscription                        app/models/user.rb:649-653 (5)
  surveys                             app/models/user.rb:119 (1)
  targeted_request_retirement         app/models/user.rb:130 (1)
  total_learning_time                 app/models/user.rb:607-619 (13)
  validate_uploaded_avatar_content_type app/models/user.rb:979-986 (8)
  wip_exists?                         app/models/user.rb:810-813 (4)
  working                             app/models/user.rb:420 (1)
  year_end_party                      app/models/user.rb:400 (1)

UserCoursePractice
  categories_for_skip_practice        app/models/user_course_practice.rb:17-25 (9)
  category_active_or_unstarted_practice app/models/user_course_practice.rb:35-41 (7)

UserCoursePracticeDecorator
  cached_completed_fraction_in_metas  app/decorators/user_course_practice_decorator.rb:16-20 (5)

UserDecorator
  address                             app/decorators/user_decorator.rb:67-73 (7)
  customer_url                        app/decorators/user_decorator.rb:28-30 (3)
  editor_or_other_editor              app/decorators/user_decorator.rb:84-88 (5)
  enrollment_period                   app/decorators/user_decorator.rb:48-58 (11)
  hibernation_days                    app/decorators/user_decorator.rb:75-77 (3)
  icon_classes                        app/decorators/user_decorator.rb:23-26 (4)
  niconico_calendar                   app/decorators/user_decorator.rb:90-96 (7)
  other_editor_checked?               app/decorators/user_decorator.rb:79-82 (4)
  private_name                        app/decorators/user_decorator.rb:44-46 (3)
  product_sidebar_class               app/decorators/user_decorator.rb:102-108 (7)
  subdivisions_of_country             app/decorators/user_decorator.rb:60-65 (6)
  subscription_url                    app/decorators/user_decorator.rb:32-34 (3)
  twitter_url                         app/decorators/user_decorator.rb:10-12 (3)

UserDecorator::ReportStatus
  unchecked_report_message            app/decorators/user_decorator/report_status.rb:17-25 (9)
  user_report_count_class             app/decorators/user_decorator/report_status.rb:13-15 (3)

UserDecorator::Retire
  countdown_danger_tag                app/decorators/user_decorator/retire.rb:22-24 (3)
  retire_deadline                     app/decorators/user_decorator/retire.rb:9-20 (12)

UserIconsController
  show                                app/controllers/user_icons_controller.rb:8-25 (18)

UserMailer
  reset_password_email                app/mailers/user_mailer.rb:4-8 (5)
  retire                              app/mailers/user_mailer.rb:20-23 (4)

UserNotificationsQuery
  query                               app/queries/user_notifications_query.rb:15-24 (10)

UserSessionsController
  callback                            app/controllers/user_sessions_controller.rb:34-49 (16)
  failure                             app/controllers/user_sessions_controller.rb:51-53 (3)
  new                                 app/controllers/user_sessions_controller.rb:6-8 (3)

UserUnstartedPracticesQuery
  query                               app/queries/user_unstarted_practices_query.rb:8-15 (8)

Users::AreasController
  show                                app/controllers/users/areas_controller.rb:11-15 (5)

Users::CommentsController
  set_comments                        app/controllers/users/comments_controller.rb:15-23 (9)
  set_user                            app/controllers/users/comments_controller.rb:11-13 (3)

Users::MailNotificationController
  edit                                app/controllers/users/mail_notification_controller.rb:9-9 (1)
  set_user                            app/controllers/users/mail_notification_controller.rb:21-23 (3)
  validate_user_access                app/controllers/users/mail_notification_controller.rb:25-28 (4)

Users::MicroReports::MicroReportComponent
  owner_post?                         app/components/users/micro_reports/micro_report_component.rb:23-25 (3)
  posted_datetime                     app/components/users/micro_reports/micro_report_component.rb:12-21 (10)

Users::MicroReportsController
  set_micro_report                    app/controllers/users/micro_reports_controller.rb:65-72 (8)
  set_user                            app/controllers/users/micro_reports_controller.rb:61-63 (3)

Users::ProductsController
  set_products                        app/controllers/users/products_controller.rb:15-21 (7)
  set_user                            app/controllers/users/products_controller.rb:11-13 (3)

Users::ReportsController
  set_current_user_practice           app/controllers/users/reports_controller.rb:45-47 (3)
  set_export                          app/controllers/users/reports_controller.rb:61-63 (3)
  set_report                          app/controllers/users/reports_controller.rb:49-51 (3)
  set_reports                         app/controllers/users/reports_controller.rb:36-43 (8)
  set_target                          app/controllers/users/reports_controller.rb:53-55 (3)
  set_unchecked_count                 app/controllers/users/reports_controller.rb:72-74 (3)
  set_user                            app/controllers/users/reports_controller.rb:32-34 (3)

Users::UsersAnswerComponent
  answer_class                        app/components/users/users_answer_component.rb:8-14 (7)
  best_answer?                        app/components/users/users_answer_component.rb:33-35 (3)
  formatted_updated_at                app/components/users/users_answer_component.rb:20-22 (3)
  question_user_avatar                app/components/users/users_answer_component.rb:37-44 (8)
  role_class                          app/components/users/users_answer_component.rb:16-18 (3)

UsersController
  created                             app/controllers/users_controller.rb:83-86 (4)
  new                                 app/controllers/users_controller.rb:58-63 (6)
  require_token                       app/controllers/users_controller.rb:222-227 (6)
  set_user                            app/controllers/users_controller.rb:218-220 (3)
  show                                app/controllers/users_controller.rb:36-56 (21)
  toggle_show_study_streak            app/controllers/users_controller.rb:88-93 (6)

UsersHelper
  all_countries_with_subdivisions     app/helpers/users_helper.rb:69-74 (6)
  button_label                        app/helpers/users_helper.rb:56-62 (7)
  desc_paragraphs                     app/helpers/users_helper.rb:64-67 (4)
  event_navs                          app/helpers/users_helper.rb:106-111 (6)
  job_seekings_for_select             app/helpers/users_helper.rb:86-92 (7)
  jobs_for_select                     app/helpers/users_helper.rb:81-84 (4)
  payment_methods_for_select          app/helpers/users_helper.rb:94-100 (7)
  roles_for_select                    app/helpers/users_helper.rb:76-79 (4)
  user_github_url                     app/helpers/users_helper.rb:13-15 (3)
  user_submit_label                   app/helpers/users_helper.rb:17-29 (13)
  user_tab_attrs                      app/helpers/users_helper.rb:4-11 (8)
  users_name                          app/helpers/users_helper.rb:52-54 (3)
  users_tags_gradation                app/helpers/users_helper.rb:41-50 (10)
  users_tags_rank                     app/helpers/users_helper.rb:31-39 (9)
  visible_learning_time_frames?       app/helpers/users_helper.rb:102-104 (3)

Watchable
  time                                app/models/concerns/watchable.rb:50-58 (9)
  watched                             app/models/concerns/watchable.rb:9 (1)

Webhook
  SECREDT                             app/models/webhook.rb:5 (1)

WelcomeController
  buzzes                              app/controllers/welcome_controller.rb:51-55 (5)
  choose_courses                      app/controllers/welcome_controller.rb:70-73 (4)
  coc                                 app/controllers/welcome_controller.rb:57-57 (1)
  faq                                 app/controllers/welcome_controller.rb:27-37 (11)
  job_support                         app/controllers/welcome_controller.rb:21-23 (3)
  law                                 app/controllers/welcome_controller.rb:49-49 (1)
  pp                                  app/controllers/welcome_controller.rb:47-47 (1)
  press_kit                           app/controllers/welcome_controller.rb:59-61 (3)
  pricing                             app/controllers/welcome_controller.rb:25-25 (1)
  rails_developer_course              app/controllers/welcome_controller.rb:65-68 (4)
  require_admin                       app/controllers/welcome_controller.rb:78-82 (5)
  tos                                 app/controllers/welcome_controller.rb:45-45 (1)
  training                            app/controllers/welcome_controller.rb:39-41 (3)

Work
  url_or_repository                   app/models/work.rb:34-36 (3)

WorkDecorator
  thumbnail_image                     app/decorators/work_decorator.rb:4-6 (3)

Works::WorkComponent
  creator_avatar                      app/components/works/work_component.rb:16-18 (3)

WorksController
  edit                                app/controllers/works_controller.rb:24-24 (1)
  new                                 app/controllers/works_controller.rb:20-22 (3)
  set_my_work                         app/controllers/works_controller.rb:64-70 (7)
  show                                app/controllers/works_controller.rb:16-18 (3)

Total suspect LOC: 4211
```



## 未参照パーシャル候補

- `app/views/admin/corporate_training_inquiries/_inquiries_item.html.slim` (`admin/corporate_training_inquiries/inquiries_item`)
- `app/views/admin/grant_course_applications/_grant_course_application.html.slim` (`admin/grant_course_applications/grant_course_application`)
- `app/views/admin/inquiries/_inquiries_item.html.slim` (`admin/inquiries/inquiries_item`)
- `app/views/announcements/_announcement.html.slim` (`announcements/announcement`)
- `app/views/announcements/_recent_announcements.html.slim` (`announcements/recent_announcements`)
- `app/views/api/practices/_started_students.json.jbuilder` (`api/practices/started_students`)
- `app/views/application/_privacy.slim` (`application/privacy`)
- `app/views/coding_tests/coding_test_submissions/_coding_test_submission.html.slim` (`coding_tests/coding_test_submissions/coding_test_submission`)
- `app/views/companies/products/_product.html.slim` (`companies/products/product`)
- `app/views/companies/users/_user.html.slim` (`companies/users/user`)
- `app/views/courses/practices/_practice_user_icon.html.slim` (`courses/practices/practice_user_icon`)
- `app/views/external_entries/_external_entry.html.slim` (`external_entries/external_entry`)
- `app/views/home/_announcements.html.slim` (`home/announcements`)
- `app/views/home/_colleague.html.slim` (`home/colleague`)
- `app/views/home/_colleague_trainee.html.slim` (`home/colleague_trainee`)
- `app/views/home/_colleague_trainee_recent_report.html.slim` (`home/colleague_trainee_recent_report`)
- `app/views/home/_recent_report.html.slim` (`home/recent_report`)
- `app/views/home/_recent_reports.html.slim` (`home/recent_reports`)
- `app/views/home/_reserved_seats_today.html.slim` (`home/reserved_seats_today`)
- `app/views/home/_upcoming_pair_work.html.slim` (`home/upcoming_pair_work`)
- `app/views/kaminari/_first_page.html.slim` (`kaminari/first_page`)
- `app/views/kaminari/_last_page.html.slim` (`kaminari/last_page`)
- `app/views/kaminari/_next_page.html.slim` (`kaminari/next_page`)
- `app/views/kaminari/_page.html.slim` (`kaminari/page`)
- `app/views/kaminari/_paginator.html.slim` (`kaminari/paginator`)
- `app/views/kaminari/_prev_page.html.slim` (`kaminari/prev_page`)
- `app/views/mentor/surveys/_survey.html.slim` (`mentor/surveys/survey`)
- `app/views/pair_works/_pair_work.html.slim` (`pair_works/pair_work`)
- `app/views/practices/coding_tests/_coding_test.html.slim` (`practices/coding_tests/coding_test`)
- `app/views/reports/_product.html.slim` (`reports/product`)
- `app/views/users/_lg_page_tabs.html.slim` (`users/lg_page_tabs`)
- `app/views/users/_page_tabs.html.slim` (`users/page_tabs`)
- `app/views/users/_unchecked.html.slim` (`users/unchecked`)
- `app/views/users/comments/_comment.html.slim` (`users/comments/comment`)
- `app/views/welcome/_buzz_mobile_filter.html.slim` (`welcome/buzz_mobile_filter`)
- `app/views/welcome/_buzz_pc_filter.html.slim` (`welcome/buzz_pc_filter`)
- `app/views/welcome/_cases.html.slim` (`welcome/cases`)
- `app/views/welcome/certified_reskill_courses/rails_developer_course/_regulations_text.html.slim` (`welcome/certified_reskill_courses/rails_developer_course/regulations_text`)

## 未参照ヘルパーメソッド候補

- `app/helpers/application_helper.rb:4` `my_practice?`
- `app/helpers/application_helper.rb:10` `movie_available?`
- `app/helpers/application_helper.rb:14` `pair_work_available?`
- `app/helpers/articles_helper.rb:8` `thumbnail_blank?`
- `app/helpers/articles_helper.rb:22` `feature_tag?`
- `app/helpers/body_class_helper.rb:36` `admin_page?`
- `app/helpers/comment_helper.rb:4` `latest_comment?`
- `app/helpers/comments_helper.rb:4` `user_comments_page?`
- `app/helpers/layout_helper.rb:4` `display_header?`
- `app/helpers/layout_helper.rb:8` `display_global_nav?`
- `app/helpers/layout_helper.rb:12` `display_footer?`
- `app/helpers/layout_helper.rb:16` `display_forms?`
- `app/helpers/markdown_helper.rb:35` `process_markdown_case`
- `app/helpers/notifications_helper.rb:4` `ensure_notifications?`
- `app/helpers/page_tabs/products_helper.rb:5` `products_page_tabs`
- `app/helpers/pair_works_helper.rb:19` `schedule_check_disabled?`
- `app/helpers/pair_works_helper.rb:28` `learning_time_frame_checked?`
- `app/helpers/procedure_helper.rb:4` `procedure`
- `app/helpers/products_helper.rb:23` `not_responded_sign?`
- `app/helpers/users_helper.rb:4` `user_tab_attrs`
- `app/helpers/users_helper.rb:102` `visible_learning_time_frames?`
