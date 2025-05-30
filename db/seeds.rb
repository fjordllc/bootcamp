# frozen_string_literal: true

require 'active_record/fixtures'

# 依存関係を考慮した順番に読み込む
#
# デフォルトではアルファベット順になってしまうため、
# 下記のように手動で順番を指定している。
tables = %i[
  acts_as_taggable_on/taggings
  acts_as_taggable_on/tags
  users
  announcements
  answers
  articles
  bookmarks
  campaigns
  categories
  checks
  comments
  companies
  corporate_training_inquiries
  correct_answers
  courses
  courses_categories
  discord_profiles
  events
  external_entries
  faq_categories
  faqs
  followings
  reports
  learning_times
  learning_time_frames
  learnings
  notifications
  participations
  practices
  categories_practices
  pages
  books
  practices_books
  products
  questions
  submission_answers
  reactions
  watches
  works
  talks
  regular_events
  regular_event_repeat_rules
  regular_event_participations
  organizers
  hibernations
  footprints
  authored_books
  survey_questions
  linear_scales
  radio_buttons
  radio_button_choices
  check_boxes
  check_box_choices
  surveys
  survey_question_listings
  survey_answers
  survey_question_answers
  buzzes
  inquiries
  movies
  coding_tests
  coding_test_cases
  coding_test_submissions
  skipped_practices
  grant_course_applications
  practices_movies
  micro_reports
]

ActiveRecord::FixtureSet.create_fixtures 'db/fixtures', tables
Bootcamp::Setup.attachment if Rails.env.development?
