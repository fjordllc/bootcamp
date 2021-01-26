# frozen_string_literal: true

require 'active_record/fixtures'

FIXTURES = %i[
  users
  announcements
  answers
  articles
  books
  borrowings
  categories
  checks
  comments
  companies
  correct_answers
  courses
  events
  followings
  reports
  learning_times
  learnings
  memos
  notifications
  pages
  participations
  practices
  products
  questions
  reactions
  reservations
  seats
  watches
  works
]

ActiveRecord::FixtureSet.create_fixtures 'db/fixtures', FIXTURES



#rake::Task['db:fixtures:load'].execute
#rake::Task['bootcamp:statistics:save_learning_minute_statistics'].execute
