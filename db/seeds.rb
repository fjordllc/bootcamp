# frozen_string_literal: true

require 'active_record/fixtures'

def insert_fixture(table)
  puts "start insert #{table}"
  ActiveRecord::FixtureSet.create_fixtures 'db/fixtures', table
end

insert_fixture 'acts_as_taggable_on/taggings'
insert_fixture 'acts_as_taggable_on/tags'
insert_fixture 'users'
insert_fixture 'announcements'
insert_fixture 'answers'
insert_fixture 'articles'
insert_fixture 'bookmarks'
insert_fixture 'categories'
insert_fixture 'checks'
insert_fixture 'comments'
insert_fixture 'companies'
insert_fixture 'correct_answers'
insert_fixture 'courses'
insert_fixture 'courses_categories'
insert_fixture 'events'
insert_fixture 'followings'
insert_fixture 'reports'
insert_fixture 'learning_times'
insert_fixture 'learnings'
insert_fixture 'memos'
insert_fixture 'notifications'
insert_fixture 'participations'
insert_fixture 'practices'
insert_fixture 'pages'
insert_fixture 'reference_books'
insert_fixture 'products'
insert_fixture 'questions'
insert_fixture 'reactions'
insert_fixture 'watches'
insert_fixture 'works'
insert_fixture 'talks'
