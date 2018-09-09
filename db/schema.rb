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

ActiveRecord::Schema.define(version: 2018_09_09_204625) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "feed_subscriptions", force: :cascade do |t|
    t.bigint "feed_id", null: false
    t.bigint "user_id", null: false
    t.boolean "autopost", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feed_id"], name: "index_feed_subscriptions_on_feed_id"
    t.index ["user_id"], name: "index_feed_subscriptions_on_user_id"
  end

  create_table "feeds", force: :cascade do |t|
    t.string "url", null: false
    t.string "title", default: "", null: false
    t.string "home_page_url", default: "", null: false
    t.datetime "refreshed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["url"], name: "index_feeds_on_url", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "username", default: ""
    t.string "name", default: ""
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "provider"
    t.string "uid"
    t.string "twitter_access_token"
    t.string "twitter_access_secret"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "feed_subscriptions", "feeds"
  add_foreign_key "feed_subscriptions", "users"
end
