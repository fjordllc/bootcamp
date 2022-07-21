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
  categories
  checks
  comments
  companies
  correct_answers
  courses
  courses_categories
  events
  followings
  reports
  learning_times
  learnings
  memos
  notifications
  participations
  practices
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
  organizers
  hibernations
]

ActiveRecord::FixtureSet.create_fixtures 'db/fixtures', tables
Bootcamp::Setup.attachment if Rails.env.development?
