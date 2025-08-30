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

ActiveRecord::Schema[8.1].define(version: 2026_01_19_100001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", precision: nil, null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "announcements", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "description", null: false
    t.datetime "published_at", precision: nil
    t.integer "target", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "user_id"
    t.boolean "wip", default: false, null: false
    t.index ["user_id"], name: "index_announcements_on_user_id"
  end

  create_table "answers", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.text "description"
    t.integer "question_id"
    t.string "type"
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
    t.index ["question_id", "type"], name: "index_answers_on_question_id_and_type", unique: true
    t.index ["question_id"], name: "index_answers_on_question_id"
    t.index ["user_id"], name: "index_answers_on_user_id"
  end

  create_table "articles", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", precision: nil, null: false
    t.boolean "display_thumbnail_in_body", default: true, null: false
    t.datetime "published_at", precision: nil
    t.text "summary"
    t.integer "target"
    t.integer "thumbnail_type", default: 0, null: false
    t.string "title"
    t.string "token"
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "user_id"
    t.boolean "wip", default: false, null: false
    t.index ["user_id"], name: "index_articles_on_user_id"
  end

  create_table "authored_books", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.string "url"
    t.bigint "user_id"
    t.index ["user_id"], name: "index_authored_books_on_user_id"
  end

  create_table "bookmarks", force: :cascade do |t|
    t.bigint "bookmarkable_id", null: false
    t.string "bookmarkable_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["bookmarkable_id", "bookmarkable_type", "user_id"], name: "index_bookmarks_unique", unique: true
    t.index ["bookmarkable_type", "bookmarkable_id"], name: "index_bookmarks_on_bookmarkable"
  end

  create_table "books", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "page_url", null: false
    t.integer "price", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
  end

  create_table "buzzes", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "campaigns", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "end_at", precision: nil, null: false
    t.datetime "start_at", precision: nil, null: false
    t.string "title", null: false
    t.integer "trial_period"
    t.datetime "updated_at", null: false
  end

  create_table "categories", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.text "description"
    t.string "name", limit: 255
    t.string "slug", limit: 255
    t.datetime "updated_at", precision: nil
  end

  create_table "categories_practices", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.datetime "created_at", precision: nil
    t.integer "position"
    t.bigint "practice_id", null: false
    t.datetime "updated_at", precision: nil
    t.index ["category_id", "practice_id"], name: "index_categories_practices_on_category_id_and_practice_id"
    t.index ["position"], name: "index_categories_practices_on_position"
    t.index ["practice_id", "category_id"], name: "index_categories_practices_on_practice_id_and_category_id"
  end

  create_table "check_box_choices", force: :cascade do |t|
    t.bigint "check_box_id"
    t.string "choices"
    t.datetime "created_at", null: false
    t.boolean "reason_for_choice_required"
    t.datetime "updated_at", null: false
    t.index ["check_box_id"], name: "index_check_box_choices_on_check_box_id"
  end

  create_table "check_boxes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description_of_reason"
    t.bigint "survey_question_id"
    t.string "title_of_reason"
    t.datetime "updated_at", null: false
    t.index ["survey_question_id"], name: "index_check_boxes_on_survey_question_id"
  end

  create_table "checks", id: :serial, force: :cascade do |t|
    t.integer "checkable_id", null: false
    t.string "checkable_type", default: "Report"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id", null: false
    t.index ["checkable_id"], name: "index_checks_on_checkable_id"
    t.index ["user_id", "checkable_id", "checkable_type"], name: "index_checks_on_user_id_and_checkable_id_and_checkable_type", unique: true
    t.index ["user_id"], name: "index_checks_on_user_id"
  end

  create_table "coding_test_cases", force: :cascade do |t|
    t.bigint "coding_test_id", null: false
    t.datetime "created_at", null: false
    t.text "input"
    t.text "output"
    t.datetime "updated_at", null: false
    t.index ["coding_test_id"], name: "index_coding_test_cases_on_coding_test_id"
  end

  create_table "coding_test_submissions", force: :cascade do |t|
    t.text "code", null: false
    t.bigint "coding_test_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["coding_test_id", "user_id"], name: "index_coding_test_submissions_on_coding_test_id_and_user_id", unique: true
    t.index ["coding_test_id"], name: "index_coding_test_submissions_on_coding_test_id"
    t.index ["user_id"], name: "index_coding_test_submissions_on_user_id"
  end

  create_table "coding_tests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.text "hint"
    t.integer "language", null: false
    t.integer "position"
    t.bigint "practice_id", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["practice_id"], name: "index_coding_tests_on_practice_id"
    t.index ["user_id"], name: "index_coding_tests_on_user_id"
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.integer "commentable_id"
    t.string "commentable_type", default: "Report"
    t.datetime "created_at", precision: nil
    t.text "description"
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
    t.index ["commentable_id"], name: "index_comments_on_commentable_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "companies", id: :serial, force: :cascade do |t|
    t.string "blog_url"
    t.datetime "created_at", precision: nil
    t.text "description"
    t.text "memo"
    t.string "name", limit: 255
    t.text "tos"
    t.datetime "updated_at", precision: nil
    t.string "website", limit: 255
  end

  create_table "corporate_training_inquiries", force: :cascade do |t|
    t.text "additional_information"
    t.string "company_name", null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "how_did_you_hear", null: false
    t.datetime "meeting_date1", precision: nil, null: false
    t.datetime "meeting_date2", precision: nil, null: false
    t.datetime "meeting_date3", precision: nil, null: false
    t.string "name", null: false
    t.integer "participants_count", null: false
    t.string "training_duration", null: false
    t.datetime "updated_at", null: false
  end

  create_table "courses", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "description", null: false
    t.boolean "grant", default: false, null: false
    t.boolean "published", default: false, null: false
    t.text "summary"
    t.string "title", null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "courses_categories", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.bigint "course_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.integer "position", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["course_id", "category_id"], name: "index_courses_categories_on_course_id_and_category_id", unique: true
  end

  create_table "discord_profiles", force: :cascade do |t|
    t.string "account_name"
    t.datetime "created_at", null: false
    t.string "times_id"
    t.string "times_url"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_discord_profiles_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.integer "capacity", null: false
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.datetime "end_at", precision: nil, null: false
    t.boolean "job_hunting", default: false, null: false
    t.string "location", null: false
    t.datetime "open_end_at", precision: nil, null: false
    t.datetime "open_start_at", precision: nil, null: false
    t.datetime "published_at", precision: nil
    t.datetime "start_at", precision: nil, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.boolean "wip", default: false, null: false
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "external_entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "published_at", precision: nil
    t.string "summary"
    t.string "thumbnail_image_url"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_external_entries_on_user_id"
  end

  create_table "faq_categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "position"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_faq_categories_on_name", unique: true
  end

  create_table "faqs", force: :cascade do |t|
    t.text "answer", null: false
    t.datetime "created_at", null: false
    t.bigint "faq_category_id", null: false
    t.integer "position"
    t.string "question", null: false
    t.datetime "updated_at", null: false
    t.index ["answer", "question"], name: "index_faqs_on_answer_and_question", unique: true
    t.index ["faq_category_id"], name: "index_faqs_on_faq_category_id"
    t.index ["question"], name: "index_faqs_on_question", unique: true
  end

  create_table "followings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "followed_id"
    t.integer "follower_id"
    t.datetime "updated_at", null: false
    t.boolean "watch", default: true, null: false
    t.index ["followed_id"], name: "index_followings_on_followed_id"
    t.index ["follower_id", "followed_id"], name: "index_followings_on_follower_id_and_followed_id", unique: true
    t.index ["follower_id"], name: "index_followings_on_follower_id"
  end

  create_table "footprints", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "footprintable_id", null: false
    t.string "footprintable_type", default: "Report"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id", null: false
    t.index ["footprintable_id"], name: "index_footprints_on_footprintable_id"
    t.index ["user_id", "footprintable_id", "footprintable_type"], name: "index_footprintable", unique: true
    t.index ["user_id"], name: "index_footprints_on_user_id"
  end

  create_table "grant_course_applications", force: :cascade do |t|
    t.string "address1", null: false
    t.string "address2"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.integer "prefecture_code", null: false
    t.string "tel1", null: false
    t.string "tel2", null: false
    t.string "tel3", null: false
    t.boolean "trial_period", default: false, null: false
    t.datetime "updated_at", null: false
    t.string "zip1", null: false
    t.string "zip2", null: false
    t.index ["email"], name: "index_grant_course_applications_on_email"
  end

  create_table "hibernations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "reason", null: false
    t.date "returned_at"
    t.date "scheduled_return_on", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_hibernations_on_user_id"
  end

  create_table "images", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "image_meta"
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_images_on_user_id"
  end

  create_table "inquiries", force: :cascade do |t|
    t.boolean "action_completed", default: false, null: false
    t.text "body"
    t.datetime "completed_at"
    t.bigint "completed_by_user_id"
    t.datetime "created_at", precision: nil, null: false
    t.string "email"
    t.string "name"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["completed_by_user_id"], name: "index_inquiries_on_completed_by_user_id"
  end

  create_table "learning_minute_statistics", force: :cascade do |t|
    t.integer "average", null: false
    t.datetime "created_at", null: false
    t.integer "median", null: false
    t.bigint "practice_id"
    t.datetime "updated_at", null: false
    t.index ["practice_id"], name: "index_learning_minute_statistics_on_practice_id"
  end

  create_table "learning_time_frames", force: :cascade do |t|
    t.integer "activity_time", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "week_day", null: false
  end

  create_table "learning_time_frames_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "learning_time_frame_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["learning_time_frame_id"], name: "index_learning_time_frames_users_on_learning_time_frame_id"
    t.index ["user_id"], name: "index_learning_time_frames_users_on_user_id"
  end

  create_table "learning_times", force: :cascade do |t|
    t.datetime "finished_at", precision: nil, null: false
    t.bigint "report_id"
    t.datetime "started_at", precision: nil, null: false
    t.index ["report_id"], name: "index_learning_times_on_report_id"
  end

  create_table "learnings", id: :serial, force: :cascade do |t|
    t.boolean "completion_message_displayed", default: false, null: false
    t.datetime "created_at", precision: nil
    t.integer "practice_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", precision: nil
    t.integer "user_id", null: false
    t.index ["user_id", "practice_id"], name: "index_learnings_on_user_id_and_practice_id", unique: true
    t.index ["user_id", "status"], name: "index_learnings_on_user_id_and_status"
  end

  create_table "linear_scales", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description_of_reason"
    t.string "first"
    t.string "last"
    t.boolean "reason_for_choice_required", default: false
    t.bigint "survey_question_id"
    t.string "title_of_reason"
    t.datetime "updated_at", null: false
    t.index ["survey_question_id"], name: "index_linear_scales_on_survey_question_id"
  end

  create_table "micro_reports", force: :cascade do |t|
    t.bigint "comment_user_id"
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_micro_reports_on_user_id"
  end

  create_table "movies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "published_at", precision: nil
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.boolean "wip", default: false, null: false
    t.index ["user_id"], name: "index_movies_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "kind", default: 0, null: false
    t.string "link"
    t.string "message"
    t.boolean "read", default: false, null: false
    t.integer "sender_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "user_id"
    t.index ["created_at"], name: "index_notifications_on_created_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.bigint "application_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.bigint "resource_owner_id", null: false
    t.datetime "revoked_at", precision: nil
    t.string "scopes", default: "", null: false
    t.string "token", null: false
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["resource_owner_id"], name: "index_oauth_access_grants_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.bigint "application_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.integer "expires_in"
    t.string "previous_refresh_token", default: "", null: false
    t.string "refresh_token"
    t.bigint "resource_owner_id"
    t.datetime "revoked_at", precision: nil
    t.string "scopes"
    t.string "token", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.string "secret", null: false
    t.string "uid", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "organizers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "regular_event_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["regular_event_id"], name: "index_organizers_on_regular_event_id"
    t.index ["user_id", "regular_event_id"], name: "index_organizers_on_user_id_and_regular_event_id", unique: true
    t.index ["user_id"], name: "index_organizers_on_user_id"
  end

  create_table "pages", id: :serial, force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", precision: nil, null: false
    t.integer "last_updated_user_id"
    t.bigint "practice_id"
    t.datetime "published_at", precision: nil
    t.string "slug", limit: 200
    t.string "title", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "user_id"
    t.boolean "wip", default: false, null: false
    t.index ["practice_id"], name: "index_pages_on_practice_id"
    t.index ["slug"], name: "index_pages_on_slug", unique: true
    t.index ["updated_at"], name: "index_pages_on_updated_at"
    t.index ["user_id"], name: "index_pages_on_user_id"
  end

  create_table "pair_works", force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.datetime "reserved_at"
    t.bigint "user_id", null: false
    t.bigint "practice_id"
    t.bigint "buddy_id"
    t.datetime "published_at"
    t.boolean "wip", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "channel", default: "ペアワーク・モブワーク1", null: false
    t.index ["buddy_id"], name: "index_pair_works_on_buddy_id"
    t.index ["practice_id"], name: "index_pair_works_on_practice_id"
    t.index ["published_at"], name: "index_pair_works_on_published_at"
    t.index ["user_id"], name: "index_pair_works_on_user_id"
  end

  create_table "participations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "enable", default: false, null: false
    t.bigint "event_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["event_id"], name: "index_participations_on_event_id"
    t.index ["user_id", "event_id"], name: "index_participations_on_user_id_and_event_id", unique: true
    t.index ["user_id"], name: "index_participations_on_user_id"
  end

  create_table "practices", id: :serial, force: :cascade do |t|
    t.integer "category_id"
    t.datetime "created_at", precision: nil
    t.text "description"
    t.text "goal"
    t.boolean "include_progress", default: true, null: false
    t.integer "last_updated_user_id"
    t.text "memo"
    t.boolean "open_product", default: false, null: false
    t.integer "source_id"
    t.boolean "submission", default: false, null: false
    t.text "summary"
    t.string "title", limit: 255, null: false
    t.datetime "updated_at", precision: nil
    t.index ["category_id"], name: "index_practices_on_category_id"
    t.index ["source_id"], name: "index_practices_on_source_id"
  end

  create_table "practices_books", force: :cascade do |t|
    t.bigint "book_id"
    t.datetime "created_at", null: false
    t.boolean "must_read", default: false, null: false
    t.bigint "practice_id"
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_practices_books_on_book_id"
    t.index ["practice_id"], name: "index_practices_books_on_practice_id"
  end

  create_table "practices_movies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "movie_id"
    t.bigint "practice_id"
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "index_practices_movies_on_movie_id"
    t.index ["practice_id"], name: "index_practices_movies_on_practice_id"
  end

  create_table "practices_reports", id: false, force: :cascade do |t|
    t.integer "practice_id", null: false
    t.integer "report_id", null: false
    t.index ["practice_id", "report_id"], name: "index_practices_reports_on_practice_id_and_report_id", unique: true
    t.index ["report_id", "practice_id"], name: "index_practices_reports_on_report_id_and_practice_id"
  end

  create_table "products", force: :cascade do |t|
    t.text "body"
    t.bigint "checker_id"
    t.datetime "commented_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "mentor_last_commented_at", precision: nil
    t.bigint "practice_id"
    t.datetime "published_at", precision: nil
    t.datetime "self_last_commented_at", precision: nil
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "user_id"
    t.boolean "wip", default: false, null: false
    t.index ["commented_at"], name: "index_products_on_commented_at"
    t.index ["practice_id"], name: "index_products_on_practice_id"
    t.index ["user_id", "practice_id"], name: "index_products_on_user_id_and_practice_id", unique: true
    t.index ["user_id"], name: "index_products_on_user_id"
  end

  create_table "questions", id: :serial, force: :cascade do |t|
    t.text "ai_answer"
    t.datetime "created_at", precision: nil
    t.text "description"
    t.bigint "practice_id"
    t.datetime "published_at", precision: nil
    t.string "title"
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
    t.boolean "wip", default: false, null: false
    t.index ["practice_id"], name: "index_questions_on_practice_id"
    t.index ["user_id"], name: "index_questions_on_user_id"
  end

  create_table "radio_button_choices", force: :cascade do |t|
    t.string "choices"
    t.datetime "created_at", null: false
    t.bigint "radio_button_id"
    t.boolean "reason_for_choice_required"
    t.datetime "updated_at", null: false
    t.index ["radio_button_id"], name: "index_radio_button_choices_on_radio_button_id"
  end

  create_table "radio_buttons", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description_of_reason"
    t.bigint "survey_question_id"
    t.string "title_of_reason"
    t.datetime "updated_at", null: false
    t.index ["survey_question_id"], name: "index_radio_buttons_on_survey_question_id"
  end

  create_table "reactions", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "kind", default: 0, null: false
    t.bigint "reactionable_id"
    t.string "reactionable_type"
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "user_id"
    t.index ["reactionable_type", "reactionable_id"], name: "index_reactions_on_reactionable_type_and_reactionable_id"
    t.index ["user_id", "reactionable_id", "reactionable_type", "kind"], name: "index_reactions_on_reactionable", unique: true
    t.index ["user_id"], name: "index_reactions_on_user_id"
  end

  create_table "regular_event_participations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "regular_event_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["regular_event_id"], name: "index_regular_event_participations_on_regular_event_id"
    t.index ["user_id", "regular_event_id"], name: "index_user_id_and_regular_event_id", unique: true
    t.index ["user_id"], name: "index_regular_event_participations_on_user_id"
  end

  create_table "regular_event_repeat_rules", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "day_of_the_week", null: false
    t.integer "frequency", null: false
    t.bigint "regular_event_id"
    t.datetime "updated_at", null: false
    t.index ["regular_event_id"], name: "index_regular_event_repeat_rules_on_regular_event_id"
  end

  create_table "regular_events", force: :cascade do |t|
    t.boolean "all", default: false, null: false
    t.integer "category", default: 0, null: false
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.time "end_at", null: false
    t.boolean "finished", null: false
    t.boolean "hold_national_holiday", null: false
    t.datetime "published_at", precision: nil
    t.time "start_at", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.boolean "wip", default: false, null: false
    t.index ["end_at"], name: "index_regular_events_on_end_at"
    t.index ["finished"], name: "index_regular_events_on_finished"
    t.index ["start_at"], name: "index_regular_events_on_start_at"
    t.index ["user_id"], name: "index_regular_events_on_user_id"
  end

  create_table "report_templates", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_report_templates_on_user_id"
  end

  create_table "reports", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.text "description"
    t.integer "emotion"
    t.datetime "published_at", precision: nil
    t.date "reported_on"
    t.string "title", limit: 255, null: false
    t.datetime "updated_at", precision: nil
    t.integer "user_id", null: false
    t.boolean "wip", default: false, null: false
    t.index ["created_at"], name: "index_reports_on_created_at"
    t.index ["user_id", "reported_on"], name: "index_reports_on_user_id_and_reported_on", unique: true
    t.index ["user_id", "title"], name: "index_reports_on_user_id_and_title", unique: true
    t.index ["user_id"], name: "reports_user_id"
  end

  create_table "request_retirements", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "keep_data", default: true, null: false
    t.text "reason"
    t.bigint "target_user_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["target_user_id"], name: "index_request_retirements_on_target_user_id", unique: true
    t.index ["user_id"], name: "index_request_retirements_on_user_id"
  end

  create_table "schedules", force: :cascade do |t|
    t.bigint "pair_work_id", null: false
    t.datetime "proposed_at", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["pair_work_id"], name: "index_schedules_on_pair_work_id"
  end

  create_table "skipped_practices", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "practice_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id", "practice_id"], name: "index_skipped_practices_on_user_id_and_practice_id", unique: true
  end

  create_table "solid_cache_entries", force: :cascade do |t|
    t.integer "byte_size", null: false
    t.datetime "created_at", null: false
    t.binary "key", null: false
    t.bigint "key_hash", null: false
    t.binary "value", null: false
    t.index ["byte_size"], name: "index_solid_cache_entries_on_byte_size"
    t.index ["key_hash", "byte_size"], name: "index_solid_cache_entries_on_key_hash_and_byte_size"
    t.index ["key_hash"], name: "index_solid_cache_entries_on_key_hash", unique: true
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.string "concurrency_key", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error"
    t.bigint "job_id", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "active_job_id"
    t.text "arguments"
    t.string "class_name", null: false
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "finished_at"
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at"
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "queue_name", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hostname"
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.text "metadata"
    t.string "name", null: false
    t.integer "pid", null: false
    t.bigint "supervisor_id"
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.datetime "run_at", null: false
    t.string "task_key", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.text "arguments"
    t.string "class_name"
    t.string "command", limit: 2048
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.integer "priority", default: 0
    t.string "queue_name"
    t.string "schedule", null: false
    t.boolean "static", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.integer "value", default: 1, null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "submission_answers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.bigint "practice_id", null: false
    t.datetime "updated_at", null: false
    t.index ["practice_id"], name: "index_submission_answers_on_practice_id"
  end

  create_table "survey_answers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "survey_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["survey_id", "user_id"], name: "index_survey_answers_on_survey_id_and_user_id", unique: true
    t.index ["survey_id"], name: "index_survey_answers_on_survey_id"
    t.index ["user_id"], name: "index_survey_answers_on_user_id"
  end

  create_table "survey_question_answers", force: :cascade do |t|
    t.text "answer"
    t.datetime "created_at", null: false
    t.text "reason"
    t.bigint "survey_answer_id", null: false
    t.bigint "survey_question_id", null: false
    t.datetime "updated_at", null: false
    t.index ["survey_answer_id"], name: "index_survey_question_answers_on_survey_answer_id"
    t.index ["survey_question_id"], name: "index_survey_question_answers_on_survey_question_id"
  end

  create_table "survey_question_listings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "position"
    t.bigint "survey_id", null: false
    t.bigint "survey_question_id", null: false
    t.datetime "updated_at", null: false
    t.index ["survey_id"], name: "index_survey_question_listings_on_survey_id"
    t.index ["survey_question_id"], name: "index_survey_question_listings_on_survey_question_id"
  end

  create_table "survey_questions", force: :cascade do |t|
    t.boolean "answer_required", default: false
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "format", default: 0
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_survey_questions_on_user_id"
  end

  create_table "surveys", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "end_at", precision: nil, null: false
    t.datetime "start_at", precision: nil, null: false
    t.string "title", limit: 255, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_surveys_on_user_id"
  end

  create_table "switchlet_flags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "enabled", default: false, null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_switchlet_flags_on_name", unique: true
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.string "context", limit: 128
    t.datetime "created_at", precision: nil
    t.integer "tag_id"
    t.integer "taggable_id"
    t.string "taggable_type"
    t.integer "tagger_id"
    t.string "tagger_type"
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
    t.boolean "action_completed", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_talks_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.datetime "accessed_at", precision: nil
    t.boolean "admin", default: false, null: false
    t.boolean "adviser", default: false, null: false
    t.text "after_graduation_hope"
    t.boolean "auto_retire", default: true
    t.string "blog_url", limit: 255
    t.text "career_memo"
    t.integer "career_path", default: 0, null: false
    t.integer "company_id"
    t.string "country_code"
    t.bigint "course_id"
    t.datetime "created_at", precision: nil
    t.string "crypted_password", limit: 255
    t.string "customer_id"
    t.text "description"
    t.integer "editor"
    t.string "email", limit: 255
    t.integer "experiences", default: 0, null: false
    t.string "facebook_url", limit: 255
    t.string "feed_url"
    t.string "github_account", limit: 255
    t.boolean "github_collaborator", default: false, null: false
    t.string "github_id"
    t.date "graduated_on"
    t.datetime "hibernated_at"
    t.boolean "invoice_payment", default: false, null: false
    t.integer "job"
    t.boolean "job_seeker", default: false, null: false
    t.datetime "last_activity_at"
    t.integer "last_negative_report_id"
    t.string "login_name", limit: 255, null: false
    t.boolean "mail_notification", default: true, null: false
    t.boolean "mentor", default: false, null: false
    t.text "mentor_memo"
    t.string "name", default: "", null: false
    t.string "name_kana", default: "", null: false
    t.boolean "nda", default: true, null: false
    t.boolean "negative_streak", default: false, null: false
    t.text "opinion"
    t.string "organization"
    t.integer "os"
    t.string "other_editor"
    t.text "other_referral_source"
    t.string "profile_job"
    t.string "profile_name"
    t.text "profile_text"
    t.integer "referral_source"
    t.string "remember_me_token", limit: 255
    t.datetime "remember_me_token_expires_at", precision: nil
    t.datetime "reset_password_email_sent_at", precision: nil
    t.string "reset_password_token"
    t.datetime "reset_password_token_expires_at", precision: nil
    t.text "retire_reason"
    t.bigint "retire_reasons", default: 0, null: false
    t.date "retired_on"
    t.string "salt", limit: 255
    t.integer "satisfaction"
    t.boolean "sent_student_before_auto_retire_mail", default: false
    t.boolean "sent_student_followup_message", default: false
    t.boolean "show_mentor_profile", default: true, null: false
    t.string "subdivision_code"
    t.string "subscription_id"
    t.boolean "trainee", default: false, null: false
    t.datetime "training_completed_at"
    t.date "training_ends_on"
    t.string "twitter_account", limit: 255
    t.string "unsubscribe_email_token"
    t.datetime "updated_at", precision: nil
    t.index ["course_id"], name: "index_users_on_course_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["github_id"], name: "index_users_on_github_id", unique: true
    t.index ["login_name"], name: "index_users_on_login_name", unique: true
    t.index ["remember_me_token"], name: "index_users_on_remember_me_token"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token"
  end

  create_table "watches", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id", null: false
    t.bigint "watchable_id", null: false
    t.string "watchable_type", null: false
    t.index ["watchable_type", "watchable_id", "user_id"], name: "index_watches_on_watchable_type_and_watchable_id_and_user_id", unique: true
    t.index ["watchable_type", "watchable_id"], name: "index_watches_on_watchable_type_and_watchable_id"
  end

  create_table "works", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "description"
    t.string "launch_article"
    t.string "repository"
    t.string "title"
    t.datetime "updated_at", precision: nil, null: false
    t.string "url"
    t.bigint "user_id"
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
  add_foreign_key "coding_test_cases", "coding_tests"
  add_foreign_key "coding_test_submissions", "coding_tests"
  add_foreign_key "coding_test_submissions", "users"
  add_foreign_key "coding_tests", "practices"
  add_foreign_key "coding_tests", "users"
  add_foreign_key "discord_profiles", "users"
  add_foreign_key "external_entries", "users"
  add_foreign_key "faqs", "faq_categories"
  add_foreign_key "hibernations", "users"
  add_foreign_key "images", "users"
  add_foreign_key "inquiries", "users", column: "completed_by_user_id", on_delete: :nullify
  add_foreign_key "learning_minute_statistics", "practices"
  add_foreign_key "learning_time_frames_users", "learning_time_frames"
  add_foreign_key "learning_time_frames_users", "users"
  add_foreign_key "learning_times", "reports"
  add_foreign_key "linear_scales", "survey_questions"
  add_foreign_key "micro_reports", "users"
  add_foreign_key "micro_reports", "users", column: "comment_user_id"
  add_foreign_key "movies", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "notifications", "users", column: "sender_id"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_grants", "users", column: "resource_owner_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "users", column: "resource_owner_id"
  add_foreign_key "organizers", "regular_events"
  add_foreign_key "organizers", "users"
  add_foreign_key "pages", "practices"
  add_foreign_key "pages", "users"
  add_foreign_key "pair_works", "practices"
  add_foreign_key "pair_works", "users"
  add_foreign_key "pair_works", "users", column: "buddy_id"
  add_foreign_key "participations", "events"
  add_foreign_key "participations", "users"
  add_foreign_key "practices", "practices", column: "source_id"
  add_foreign_key "practices_books", "books"
  add_foreign_key "practices_books", "practices"
  add_foreign_key "practices_movies", "movies"
  add_foreign_key "practices_movies", "practices"
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
  add_foreign_key "request_retirements", "users"
  add_foreign_key "request_retirements", "users", column: "target_user_id"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "schedules", "pair_works"
  add_foreign_key "submission_answers", "practices"
  add_foreign_key "survey_answers", "surveys"
  add_foreign_key "survey_answers", "users"
  add_foreign_key "survey_question_answers", "survey_answers"
  add_foreign_key "survey_question_answers", "survey_questions"
  add_foreign_key "survey_question_listings", "survey_questions"
  add_foreign_key "survey_question_listings", "surveys"
  add_foreign_key "survey_questions", "users"
  add_foreign_key "surveys", "users"
  add_foreign_key "talks", "users"
  add_foreign_key "works", "users"
end
