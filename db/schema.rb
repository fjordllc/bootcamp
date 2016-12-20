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

ActiveRecord::Schema.define(version: 20161216053008) do

  create_table "answers", force: :cascade do |t|
    t.text     "description"
    t.integer  "user_id"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "answers", ["question_id"], name: "index_answers_on_question_id"
  add_index "answers", ["user_id"], name: "index_answers_on_user_id"

  create_table "categories", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "slug",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.text     "description"
  end

  create_table "comments", force: :cascade do |t|
    t.text     "description"
    t.integer  "user_id"
    t.integer  "report_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["report_id"], name: "index_comments_on_report_id", using: :btree
    t.index ["user_id"], name: "index_comments_on_user_id", using: :btree
  end

  create_table "companies", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description"
    t.string   "website",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "tos"
  end

  create_table "learnings", force: :cascade do |t|
    t.integer  "user_id",                 null: false
    t.integer  "practice_id",             null: false
    t.integer  "status_cd",   default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pages", force: :cascade do |t|
    t.string   "title",      null: false
    t.text     "body",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "practices", force: :cascade do |t|
    t.string   "title",       limit: 255, null: false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "goal"
    t.integer  "category_id"
    t.integer  "position"
    t.index ["category_id"], name: "index_practices_on_category_id", using: :btree
  end

  create_table "practices_reports", id: false, force: :cascade do |t|
    t.integer "practice_id", null: false
    t.integer "report_id",   null: false
    t.index ["practice_id", "report_id"], name: "index_practices_reports_on_practice_id_and_report_id", using: :btree
    t.index ["report_id", "practice_id"], name: "index_practices_reports_on_report_id_and_practice_id", using: :btree
  end

  create_table "questions", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "correct_answer_id"
    t.index ["user_id"], name: "index_questions_on_user_id", using: :btree
  end

  add_index "practices_reports", ["practice_id", "report_id"], name: "index_practices_reports_on_practice_id_and_report_id"
  add_index "practices_reports", ["report_id", "practice_id"], name: "index_practices_reports_on_report_id_and_practice_id"

  create_table "questions", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "correct_answer_id"
  end

  add_index "questions", ["user_id"], name: "index_questions_on_user_id"

  create_table "reports", force: :cascade do |t|
    t.integer  "user_id",                 null: false
    t.string   "title",       limit: 255, null: false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "login_name",                   limit: 255,                 null: false
    t.string   "email",                        limit: 255
    t.string   "crypted_password",             limit: 255
    t.string   "salt",                         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_me_token",            limit: 255
    t.datetime "remember_me_token_expires_at"
    t.string   "first_name",                   limit: 255
    t.string   "last_name",                    limit: 255
    t.string   "twitter_url",                  limit: 255
    t.string   "facebook_url",                 limit: 255
    t.string   "blog_url",                     limit: 255
    t.integer  "company_id",                               default: 1
    t.text     "description"
    t.boolean  "find_job_assist",                          default: false, null: false
    t.integer  "purpose_cd",                               default: 0,     null: false
    t.string   "feed_url",                     limit: 255
    t.datetime "accessed_at"
    t.boolean  "graduation",                               default: false, null: false
    t.string   "github_account",               limit: 255
    t.boolean  "adviser",                                  default: false, null: false
    t.boolean  "retire",                                   default: false, null: false
    t.boolean  "nda",                                      default: true,  null: false
    t.string   "slack_account"
    t.index ["remember_me_token"], name: "index_users_on_remember_me_token", using: :btree
  end

end
