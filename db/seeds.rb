# frozen_string_literal: true

require 'active_record/fixtures'

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
  organizers
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
  regular_events
  watches
  works
  talks
]

ActiveRecord::FixtureSet.create_fixtures 'db/fixtures', tables
