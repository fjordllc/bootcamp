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
  followings
  reports
  learning_times
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
  buzzes
  inquiries
]

ActiveRecord::FixtureSet.create_fixtures 'db/fixtures', tables
Bootcamp::Setup.attachment if Rails.env.development?

# ステージング環境で日報100回目のお祝いメッセージの動作確認が終わり次第、削除します

komagata = User.find_by(login_name: 'komagata')

95.times do |i|
  Report.create!(
    user_id: komagata.id,
    title: "テスト日報 #{i + 4}",
    description: '動作確認が終わり次第、削除します',
    reported_on: Time.zone.today - (97 - i),
    wip: false,
    emotion: 2,
    created_at: Time.zone.today - (96 - i).days,
    updated_at: Time.zone.today - (96 - i).days,
    published_at: Time.zone.today - (96 - i).days
  )
end

Report.create!(
  user_id: komagata.id,
  title: 'wip日報 99',
  description: '動作確認が終わり次第、削除します',
  reported_on: Time.zone.today - 2,
  wip: true,
  emotion: 2,
  created_at: Time.zone.today - 1,
  updated_at: Time.zone.today - 1,
  published_at: Time.zone.today - 1
)
