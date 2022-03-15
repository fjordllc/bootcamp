# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_02_03_145350) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "announcements", force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.integer "target", default: 0, null: false
    t.boolean "wip", default: false, null: false
    t.datetime "published_at"
    t.index ["user_id"], name: "index_announcements_on_user_id"
  end

  create_table "answers", id: :serial, force: :cascade do |t|
    t.text "description"
    t.integer "user_id"
    t.integer "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "type"
    t.index ["question_id"], name: "index_answers_on_question_id"
    t.index ["user_id"], name: "index_answers_on_user_id"
  end

  create_table "articles", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.boolean "wip", default: false, null: false
    t.datetime "published_at"
    t.index ["user_id"], name: "index_articles_on_user_id"
  end

  create_table "bookmarks", force: :cascade do |t|
    t.string "bookmarkable_type", null: false
    t.bigint "bookmarkable_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["bookmarkable_id", "bookmarkable_type", "user_id"], name: "index_bookmarks_unique", unique: true
    t.index ["bookmarkable_type", "bookmarkable_id"], name: "index_bookmarks_on_bookmarkable"
  end

  create_table "campaigns", force: :cascade do |t|
    t.datetime "start_at", null: false
    t.datetime "end_at", null: false
    t.string "title", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "categories", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "position"
    t.text "description"
    t.index ["position"], name: "index_categories_on_position"
  end

  create_table "categories_practices", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.bigint "practice_id", null: false
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["category_id", "practice_id"], name: "index_categories_practices_on_category_id_and_practice_id"
    t.index ["position"], name: "index_categories_practices_on_position"
    t.index ["practice_id", "category_id"], name: "index_categories_practices_on_practice_id_and_category_id"
  end

  create_table "checks", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "checkable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "checkable_type", default: "Report"
    t.index ["checkable_id"], name: "index_checks_on_checkable_id"
    t.index ["user_id", "checkable_id", "checkable_type"], name: "index_checks_on_user_id_and_checkable_id_and_checkable_type", unique: true
    t.index ["user_id"], name: "index_checks_on_user_id"
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.text "description"
    t.integer "user_id"
    t.integer "commentable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "commentable_type", default: "Report"
    t.index ["commentable_id"], name: "index_comments_on_commentable_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "companies", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "website"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "tos"
    t.string "blog_url"
  end

  create_table "courses", force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "published", default: false, null: false
  end

  create_table "courses_categories", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.bigint "category_id", null: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id", "category_id"], name: "index_courses_categories_on_course_id_and_category_id", unique: true
  end

  create_table "events", force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.string "location", null: false
    t.integer "capacity", null: false
    t.datetime "start_at", null: false
    t.datetime "end_at", null: false
    t.datetime "open_start_at", null: false
    t.datetime "open_end_at", null: false
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "wip", default: false, null: false
    t.boolean "job_hunting", default: false, null: false
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "followings", force: :cascade do |t|
    t.integer "follower_id"
    t.integer "followed_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "watch", default: true, null: false
    t.index ["followed_id"], name: "index_followings_on_followed_id"
    t.index ["follower_id", "followed_id"], name: "index_followings_on_follower_id_and_followed_id", unique: true
    t.index ["follower_id"], name: "index_followings_on_follower_id"
  end

  create_table "footprints", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "footprintable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "footprintable_type", default: "Report"
    t.index ["footprintable_id"], name: "index_footprints_on_footprintable_id"
    t.index ["user_id", "footprintable_id", "footprintable_type"], name: "index_footprintable", unique: true
    t.index ["user_id"], name: "index_footprints_on_user_id"
  end

  create_table "images", force: :cascade do |t|
    t.bigint "user_id"
    t.text "image_meta"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_images_on_user_id"
  end

  create_table "inquiries", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "learning_minute_statistics", force: :cascade do |t|
    t.bigint "practice_id"
    t.integer "average", null: false
    t.integer "median", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["practice_id"], name: "index_learning_minute_statistics_on_practice_id"
  end

  create_table "learning_times", force: :cascade do |t|
    t.bigint "report_id"
    t.datetime "started_at", null: false
    t.datetime "finished_at", null: false
    t.index ["report_id"], name: "index_learning_times_on_report_id"
  end

  create_table "learnings", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "practice_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "completion_message_displayed", default: false, null: false
    t.index ["user_id", "practice_id"], name: "index_learnings_on_user_id_and_practice_id", unique: true
    t.index ["user_id", "status"], name: "index_learnings_on_user_id_and_status"
  end

  create_table "memos", force: :cascade do |t|
    t.date "date"
    t.string "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_memos_on_date", unique: true
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "kind", default: 0, null: false
    t.bigint "user_id"
    t.integer "sender_id", null: false
    t.string "message"
    t.string "link"
    t.boolean "read", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_notifications_on_created_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "pages", id: :serial, force: :cascade do |t|
    t.string "title", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.boolean "wip", default: false, null: false
    t.datetime "published_at"
    t.integer "last_updated_user_id"
    t.bigint "practice_id"
    t.string "slug", limit: 200
    t.index ["practice_id"], name: "index_pages_on_practice_id"
    t.index ["slug"], name: "index_pages_on_slug", unique: true
    t.index ["updated_at"], name: "index_pages_on_updated_at"
    t.index ["user_id"], name: "index_pages_on_user_id"
  end

  create_table "participations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "event_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "enable", default: false, null: false
    t.index ["event_id"], name: "index_participations_on_event_id"
    t.index ["user_id", "event_id"], name: "index_participations_on_user_id_and_event_id", unique: true
    t.index ["user_id"], name: "index_participations_on_user_id"
  end

  create_table "practices", id: :serial, force: :cascade do |t|
    t.string "title", limit: 255, null: false
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "goal"
    t.integer "category_id"
    t.integer "position"
    t.boolean "submission", default: false, null: false
    t.boolean "open_product", default: false, null: false
    t.boolean "include_progress", default: true, null: false
    t.text "memo"
    t.integer "last_updated_user_id"
    t.index ["category_id"], name: "index_practices_on_category_id"
  end

  create_table "practices_reports", id: false, force: :cascade do |t|
    t.integer "practice_id", null: false
    t.integer "report_id", null: false
    t.index ["practice_id", "report_id"], name: "index_practices_reports_on_practice_id_and_report_id"
    t.index ["report_id", "practice_id"], name: "index_practices_reports_on_report_id_and_practice_id"
  end

  create_table "products", force: :cascade do |t|
    t.bigint "practice_id"
    t.bigint "user_id"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "wip", default: false, null: false
    t.datetime "published_at"
    t.bigint "checker_id"
    t.datetime "self_last_commented_at"
    t.datetime "mentor_last_commented_at"
    t.datetime "commented_at"
    t.index ["commented_at"], name: "index_products_on_commented_at"
    t.index ["practice_id"], name: "index_products_on_practice_id"
    t.index ["user_id", "practice_id"], name: "index_products_on_user_id_and_practice_id", unique: true
    t.index ["user_id"], name: "index_products_on_user_id"
  end

  create_table "questions", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "practice_id"
    t.boolean "wip", default: false, null: false
    t.datetime "published_at"
    t.index ["practice_id"], name: "index_questions_on_practice_id"
    t.index ["user_id"], name: "index_questions_on_user_id"
  end

  create_table "reactions", force: :cascade do |t|
    t.bigint "user_id"
    t.string "reactionable_type"
    t.bigint "reactionable_id"
    t.integer "kind", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reactionable_type", "reactionable_id"], name: "index_reactions_on_reactionable"
    t.index ["user_id", "reactionable_id", "reactionable_type", "kind"], name: "index_reactions_on_reactionable_u_k", unique: true
    t.index ["user_id"], name: "index_reactions_on_user_id"
  end

  create_table "reference_books", force: :cascade do |t|
    t.string "title", null: false
    t.integer "price", null: false
    t.string "page_url", null: false
    t.bigint "practice_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "must_read", default: false, null: false
    t.text "description"
    t.index ["practice_id"], name: "index_reference_books_on_practice_id"
  end

  create_table "report_templates", force: :cascade do |t|
    t.bigint "user_id"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_report_templates_on_user_id"
  end

  create_table "reports", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "title", limit: 255, null: false
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date "reported_on"
    t.boolean "wip", default: false, null: false
    t.integer "emotion"
    t.datetime "published_at"
    t.index ["user_id", "reported_on"], name: "index_reports_on_user_id_and_reported_on", unique: true
    t.index ["user_id", "title"], name: "index_reports_on_user_id_and_title", unique: true
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "talks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "unreplied", default: false, null: false
    t.index ["user_id"], name: "index_talks_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "login_name", null: false
    t.string "email"
    t.string "crypted_password"
    t.string "salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "remember_me_token"
    t.datetime "remember_me_token_expires_at"
    t.string "twitter_account"
    t.string "facebook_url"
    t.string "blog_url"
    t.integer "company_id"
    t.text "description"
    t.datetime "accessed_at"
    t.string "github_account"
    t.boolean "adviser", default: false, null: false
    t.boolean "nda", default: true, null: false
    t.string "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.boolean "mentor", default: false, null: false
    t.date "graduated_on"
    t.bigint "course_id"
    t.date "retired_on"
    t.boolean "admin", default: false, null: false
    t.integer "job"
    t.string "organization"
    t.integer "os"
    t.integer "experience"
    t.text "retire_reason"
    t.boolean "trainee", default: false, null: false
    t.boolean "free", default: false, null: false
    t.string "customer_id"
    t.boolean "job_seeking", default: false, null: false
    t.string "subscription_id"
    t.boolean "mail_notification", default: true, null: false
    t.integer "prefecture_code"
    t.boolean "job_seeker", default: false, null: false
    t.string "github_id"
    t.boolean "github_collaborator", default: false, null: false
    t.string "name", default: "", null: false
    t.string "name_kana", default: "", null: false
    t.integer "satisfaction"
    t.text "opinion"
    t.bigint "retire_reasons", default: 0, null: false
    t.string "unsubscribe_email_token"
    t.text "mentor_memo"
    t.string "discord_account"
    t.string "times_url"
    t.text "after_graduation_hope"
    t.boolean "notified_retirement", default: false, null: false
    t.index ["course_id"], name: "index_users_on_course_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["github_id"], name: "index_users_on_github_id", unique: true
    t.index ["login_name"], name: "index_users_on_login_name", unique: true
    t.index ["remember_me_token"], name: "index_users_on_remember_me_token"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token"
  end

  create_table "watches", force: :cascade do |t|
    t.string "watchable_type"
    t.bigint "watchable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["watchable_type", "watchable_id"], name: "index_watches_on_watchable"
  end

  create_table "works", force: :cascade do |t|
    t.string "title"
    t.string "url"
    t.string "repository"
    t.text "description"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "title"], name: "index_works_on_user_id_and_title", unique: true
    t.index ["user_id"], name: "index_works_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "announcements", "users"
  add_foreign_key "articles", "users"
  add_foreign_key "categories_practices", "categories"
  add_foreign_key "categories_practices", "practices"
  add_foreign_key "images", "users"
  add_foreign_key "learning_minute_statistics", "practices"
  add_foreign_key "learning_times", "reports"
  add_foreign_key "notifications", "users"
  add_foreign_key "notifications", "users", column: "sender_id"
  add_foreign_key "pages", "practices"
  add_foreign_key "pages", "users"
  add_foreign_key "participations", "events"
  add_foreign_key "participations", "users"
  add_foreign_key "products", "practices"
  add_foreign_key "products", "users"
  add_foreign_key "questions", "practices"
  add_foreign_key "reactions", "users"
  add_foreign_key "reference_books", "practices"
  add_foreign_key "report_templates", "users"
  add_foreign_key "talks", "users"
  add_foreign_key "works", "users"
end
