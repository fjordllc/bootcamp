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

ActiveRecord::Schema.define(version: 2023_07_24_095814) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
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
    t.text "summary"
    t.index ["user_id"], name: "index_articles_on_user_id"
  end

  create_table "authored_books", force: :cascade do |t|
    t.string "title"
    t.string "url"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_authored_books_on_user_id"
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

  create_table "books", force: :cascade do |t|
    t.string "title", null: false
    t.integer "price", null: false
    t.string "page_url", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "description"
  end

  create_table "buzzes", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "campaigns", force: :cascade do |t|
    t.datetime "start_at", null: false
    t.datetime "end_at", null: false
    t.string "title", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "trial_period"
  end

  create_table "categories", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "slug", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "description"
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

  create_table "check_box_choices", force: :cascade do |t|
    t.bigint "check_box_id"
    t.string "choices"
    t.boolean "reason_for_choice_required"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["check_box_id"], name: "index_check_box_choices_on_check_box_id"
  end

  create_table "check_boxes", force: :cascade do |t|
    t.string "title_of_reason"
    t.text "description_of_reason"
    t.bigint "survey_question_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["survey_question_id"], name: "index_check_boxes_on_survey_question_id"
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
    t.index ["user_id"], name: "comment_user_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "companies", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.text "description"
    t.string "website", limit: 255
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

  create_table "data_migrations", primary_key: "version", id: :string, force: :cascade do |t|
  end

  create_table "discord_profiles", force: :cascade do |t|
    t.bigint "user_id"
    t.string "account_name"
    t.string "times_url"
    t.string "times_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_discord_profiles_on_user_id"
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
    t.datetime "published_at"
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "external_entries", force: :cascade do |t|
    t.string "title", null: false
    t.string "url", null: false
    t.string "summary"
    t.datetime "published_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id", null: false
    t.string "thumbnail_image_url"
    t.index ["user_id"], name: "index_external_entries_on_user_id"
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

  create_table "good_job_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "description"
    t.jsonb "serialized_properties"
    t.text "on_finish"
    t.text "on_success"
    t.text "on_discard"
    t.text "callback_queue_name"
    t.integer "callback_priority"
    t.datetime "enqueued_at"
    t.datetime "discarded_at"
    t.datetime "finished_at"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "state"
  end

  create_table "good_job_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "key"
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "queue_name"
    t.integer "priority"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "performed_at"
    t.datetime "finished_at"
    t.text "error"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "active_job_id"
    t.text "concurrency_key"
    t.text "cron_key"
    t.uuid "retried_good_job_id"
    t.datetime "cron_at"
    t.uuid "batch_id"
    t.uuid "batch_callback_id"
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["active_job_id"], name: "index_good_jobs_on_active_job_id"
    t.index ["batch_callback_id"], name: "index_good_jobs_on_batch_callback_id", where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"], name: "index_good_jobs_on_batch_id", where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at", unique: true
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at", where: "((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL))"
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "hibernations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "reason", null: false
    t.date "scheduled_return_on", null: false
    t.date "returned_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_hibernations_on_user_id"
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

  create_table "linear_scales", force: :cascade do |t|
    t.string "first"
    t.string "last"
    t.boolean "reason_for_choice_required", default: false
    t.string "title_of_reason"
    t.text "description_of_reason"
    t.bigint "survey_question_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["survey_question_id"], name: "index_linear_scales_on_survey_question_id"
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

  create_table "organizers", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "regular_event_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["regular_event_id"], name: "index_organizers_on_regular_event_id"
    t.index ["user_id", "regular_event_id"], name: "index_organizers_on_user_id_and_regular_event_id", unique: true
    t.index ["user_id"], name: "index_organizers_on_user_id"
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
    t.boolean "submission", default: false, null: false
    t.boolean "open_product", default: false, null: false
    t.boolean "include_progress", default: true, null: false
    t.text "memo"
    t.integer "last_updated_user_id"
    t.text "summary"
    t.index ["category_id"], name: "index_practices_on_category_id"
  end

  create_table "practices_books", force: :cascade do |t|
    t.bigint "practice_id"
    t.bigint "book_id"
    t.boolean "must_read", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["book_id"], name: "index_practices_books_on_book_id"
    t.index ["practice_id"], name: "index_practices_books_on_practice_id"
  end

  create_table "practices_reports", id: false, force: :cascade do |t|
    t.integer "practice_id", null: false
    t.integer "report_id", null: false
    t.index ["practice_id", "report_id"], name: "index_practices_reports_on_practice_id_and_report_id", unique: true
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
    t.text "ai_answer"
    t.index ["practice_id"], name: "index_questions_on_practice_id"
    t.index ["user_id"], name: "index_questions_on_user_id"
  end

  create_table "radio_button_choices", force: :cascade do |t|
    t.bigint "radio_button_id"
    t.string "choices"
    t.boolean "reason_for_choice_required"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["radio_button_id"], name: "index_radio_button_choices_on_radio_button_id"
  end

  create_table "radio_buttons", force: :cascade do |t|
    t.string "title_of_reason"
    t.text "description_of_reason"
    t.bigint "survey_question_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["survey_question_id"], name: "index_radio_buttons_on_survey_question_id"
  end

  create_table "reactions", force: :cascade do |t|
    t.bigint "user_id"
    t.string "reactionable_type"
    t.bigint "reactionable_id"
    t.integer "kind", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reactionable_type", "reactionable_id"], name: "index_reactions_on_reactionable_type_and_reactionable_id"
    t.index ["user_id", "reactionable_id", "reactionable_type", "kind"], name: "index_reactions_on_reactionable", unique: true
    t.index ["user_id"], name: "index_reactions_on_user_id"
  end

  create_table "regular_event_participations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "regular_event_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["regular_event_id"], name: "index_regular_event_participations_on_regular_event_id"
    t.index ["user_id", "regular_event_id"], name: "index_user_id_and_regular_event_id", unique: true
    t.index ["user_id"], name: "index_regular_event_participations_on_user_id"
  end

  create_table "regular_event_repeat_rules", force: :cascade do |t|
    t.bigint "regular_event_id"
    t.integer "frequency", null: false
    t.integer "day_of_the_week", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["regular_event_id"], name: "index_regular_event_repeat_rules_on_regular_event_id"
  end

  create_table "regular_events", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.text "description", null: false
    t.boolean "finished", null: false
    t.boolean "hold_national_holiday", null: false
    t.time "start_at", null: false
    t.time "end_at", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "wip", default: false, null: false
    t.integer "category", default: 0, null: false
    t.boolean "all", default: false, null: false
    t.datetime "published_at"
    t.index ["user_id"], name: "index_regular_events_on_user_id"
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
    t.index ["user_id"], name: "reports_user_id"
  end

  create_table "survey_question_listings", force: :cascade do |t|
    t.bigint "survey_id", null: false
    t.bigint "survey_question_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "position"
    t.index ["survey_id"], name: "index_survey_question_listings_on_survey_id"
    t.index ["survey_question_id"], name: "index_survey_question_listings_on_survey_question_id"
  end

  create_table "survey_questions", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "format", default: 0
    t.boolean "answer_required", default: false
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_survey_questions_on_user_id"
  end

  create_table "surveys", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", limit: 255, null: false
    t.text "description"
    t.datetime "start_at", null: false
    t.datetime "end_at", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_surveys_on_user_id"
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
    t.boolean "action_completed", default: true, null: false
    t.index ["user_id"], name: "index_talks_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "login_name", limit: 255, null: false
    t.string "email", limit: 255
    t.string "crypted_password", limit: 255
    t.string "salt", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "remember_me_token", limit: 255
    t.datetime "remember_me_token_expires_at"
    t.string "twitter_account", limit: 255
    t.string "facebook_url", limit: 255
    t.string "blog_url", limit: 255
    t.integer "company_id"
    t.text "description"
    t.datetime "accessed_at"
    t.string "github_account", limit: 255
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
    t.boolean "free", default: false, null: false
    t.boolean "trainee", default: false, null: false
    t.text "retire_reason"
    t.boolean "job_seeking", default: false, null: false
    t.string "customer_id"
    t.string "subscription_id"
    t.boolean "mail_notification", default: true, null: false
    t.boolean "job_seeker", default: false, null: false
    t.boolean "github_collaborator", default: false, null: false
    t.string "github_id"
    t.integer "satisfaction"
    t.text "opinion"
    t.bigint "retire_reasons", default: 0, null: false
    t.string "name", default: "", null: false
    t.string "name_kana", default: "", null: false
    t.string "unsubscribe_email_token"
    t.string "discord_account"
    t.text "mentor_memo"
    t.string "times_url"
    t.text "after_graduation_hope"
    t.date "training_ends_on"
    t.boolean "sad_streak", default: false, null: false
    t.integer "last_sad_report_id"
    t.datetime "last_activity_at"
    t.datetime "hibernated_at"
    t.string "profile_name"
    t.string "profile_job"
    t.text "profile_text"
    t.string "feed_url"
    t.string "times_id", comment: "Snowflake ID"
    t.boolean "sent_student_followup_message", default: false
    t.string "country_code"
    t.string "subdivision_code"
    t.boolean "auto_retire", default: true
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
    t.index ["watchable_type", "watchable_id", "user_id"], name: "index_watches_on_watchable_type_and_watchable_id_and_user_id", unique: true
    t.index ["watchable_type", "watchable_id"], name: "index_watches_on_watchable_type_and_watchable_id"
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
  add_foreign_key "authored_books", "users"
  add_foreign_key "categories_practices", "categories"
  add_foreign_key "categories_practices", "practices"
  add_foreign_key "check_box_choices", "check_boxes"
  add_foreign_key "check_boxes", "survey_questions"
  add_foreign_key "discord_profiles", "users"
  add_foreign_key "external_entries", "users"
  add_foreign_key "hibernations", "users"
  add_foreign_key "images", "users"
  add_foreign_key "learning_minute_statistics", "practices"
  add_foreign_key "learning_times", "reports"
  add_foreign_key "linear_scales", "survey_questions"
  add_foreign_key "notifications", "users"
  add_foreign_key "notifications", "users", column: "sender_id"
  add_foreign_key "organizers", "regular_events"
  add_foreign_key "organizers", "users"
  add_foreign_key "pages", "practices"
  add_foreign_key "pages", "users"
  add_foreign_key "participations", "events"
  add_foreign_key "participations", "users"
  add_foreign_key "practices_books", "books"
  add_foreign_key "practices_books", "practices"
  add_foreign_key "products", "practices"
  add_foreign_key "products", "users"
  add_foreign_key "questions", "practices"
  add_foreign_key "radio_button_choices", "radio_buttons"
  add_foreign_key "radio_buttons", "survey_questions"
  add_foreign_key "reactions", "users"
  add_foreign_key "regular_event_participations", "regular_events"
  add_foreign_key "regular_event_participations", "users"
  add_foreign_key "regular_event_repeat_rules", "regular_events"
  add_foreign_key "regular_events", "users"
  add_foreign_key "report_templates", "users"
  add_foreign_key "survey_question_listings", "survey_questions"
  add_foreign_key "survey_question_listings", "surveys"
  add_foreign_key "survey_questions", "users"
  add_foreign_key "surveys", "users"
  add_foreign_key "talks", "users"
  add_foreign_key "works", "users"
end
