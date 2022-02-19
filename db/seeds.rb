# frozen_string_literal: true

require 'active_record/fixtures'

ActiveRecord::FixtureSet.create_fixtures 'db/fixtures', %i[
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
  reference_books
  products
  questions
  reactions
  watches
  works
  talks
]

Bootcamp::Setup.attachment
Rake::Task['bootcamp:statistics:save_learning_minute_statistics'].execute
