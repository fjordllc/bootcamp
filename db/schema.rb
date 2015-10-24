# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20151024062526) do

  create_table "categories", force: true do |t|
    t.string   "name"
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.text     "description"
  end

  create_table "companies", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "website"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "tos"
  end

  create_table "learnings", force: true do |t|
    t.integer  "user_id",                 null: false
    t.integer  "practice_id",             null: false
    t.integer  "status_cd",   default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "practices", force: true do |t|
    t.string   "title",       null: false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "goal"
    t.integer  "category_id"
    t.integer  "position"
  end

  add_index "practices", ["category_id"], name: "index_practices_on_category_id"

  create_table "users", force: true do |t|
    t.string   "login_name",                                   null: false
    t.string   "email"
    t.string   "crypted_password"
    t.string   "salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_me_token"
    t.datetime "remember_me_token_expires_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "twitter_url"
    t.string   "facebook_url"
    t.string   "blog_url"
    t.integer  "company_id",                   default: 1
    t.text     "description"
    t.boolean  "find_job_assist",              default: false, null: false
    t.integer  "purpose_cd",                   default: 0,     null: false
    t.string   "feed_url"
    t.datetime "accessed_at"
    t.boolean  "graduation",                   default: false, null: false
    t.string   "github_account"
    t.boolean  "adviser",                      default: false, null: false
    t.boolean  "sleep",                        default: false, null: false
    t.boolean  "nda",                          default: true,  null: false
  end

  add_index "users", ["remember_me_token"], name: "index_users_on_remember_me_token"

end
