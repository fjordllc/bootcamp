# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_01_17_050043) do

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
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "announcements", force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
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

  create_table "categories", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "position"
    t.text "description"
  end

  create_table "categories_courses", id: false, force: :cascade do |t|
    t.bigint "course_id", null: false
    t.bigint "category_id", null: false
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
  end

  create_table "courses", force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "learning_times", force: :cascade do |t|
    t.bigint "report_id"
    t.datetime "started_at", null: false
    t.datetime "finished_at", null: false
    t.index ["report_id"], name: "index_learning_times_on_report_id"
  end

  create_table "learnings", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "practice_id", null: false
    t.integer "status_cd", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "kind", default: 0, null: false
    t.bigint "user_id"
    t.integer "sender_id", null: false
    t.string "message"
    t.string "path"
    t.boolean "read", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "pages", id: :serial, force: :cascade do |t|
    t.string "title", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["updated_at"], name: "index_pages_on_updated_at"
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
    t.index ["practice_id"], name: "index_products_on_practice_id"
    t.index ["user_id"], name: "index_products_on_user_id"
  end

  create_table "questions", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "practice_id"
    t.index ["practice_id"], name: "index_questions_on_practice_id"
    t.index ["user_id"], name: "index_questions_on_user_id"
  end

  create_table "reports", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "title", limit: 255, null: false
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date "reported_on"
    t.boolean "wip", default: false, null: false
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
    t.string "first_name"
    t.string "last_name"
    t.string "twitter_account"
    t.string "facebook_url"
    t.string "blog_url"
    t.integer "company_id", default: 1
    t.text "description"
    t.string "feed_url"
    t.datetime "accessed_at"
    t.string "github_account"
    t.boolean "adviser", default: false, null: false
    t.boolean "nda", default: true, null: false
    t.string "slack_account"
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
    t.integer "study_place"
    t.integer "experience"
    t.string "how_did_you_know"
    t.boolean "free", default: false, null: false
    t.boolean "trainee", default: false, null: false
    t.text "retire_reason"
    t.index ["course_id"], name: "index_users_on_course_id"
    t.index ["remember_me_token"], name: "index_users_on_remember_me_token"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token"
  end

  add_foreign_key "announcements", "users"
  add_foreign_key "images", "users"
  add_foreign_key "learning_times", "reports"
  add_foreign_key "notifications", "users"
  add_foreign_key "notifications", "users", column: "sender_id"
  add_foreign_key "products", "practices"
  add_foreign_key "products", "users"
  add_foreign_key "questions", "practices"
end
