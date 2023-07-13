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
  correct_answers
  courses
  courses_categories
  discord_profiles
  events
  external_entries
  faqs
  followings
  reports
  learning_times
  learnings
  memos
  notifications
  participations
  practices
  categories_practices
  pages
  books
  practices_books
  products
  questions
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
  buzzes
]

ActiveRecord::FixtureSet.create_fixtures 'db/fixtures', tables
Bootcamp::Setup.attachment if Rails.env.development?
