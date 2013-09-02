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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130902014029) do

  create_table "annotations", :force => true do |t|
    t.date     "fulldate"
    t.string   "note"
    t.integer  "dashboard_id"
    t.integer  "user_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "cohorts", :force => true do |t|
    t.string   "name"
    t.text     "definition"
    t.integer  "status"
    t.date     "start_date"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "configurations", :force => true do |t|
    t.string   "auth"
    t.string   "username"
    t.string   "password"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "dashboards", :force => true do |t|
    t.string   "title"
    t.float    "eta"
    t.text     "dashboard"
    t.text     "description"
    t.string   "date_from"
    t.integer  "status"
    t.string   "supplement"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "demographics", :force => true do |t|
    t.string   "name"
    t.text     "definition"
    t.text     "description"
    t.text     "refreshql"
    t.integer  "refreshql_replace"
    t.integer  "auto_assign"
    t.integer  "initial_population"
    t.integer  "cached_population"
    t.integer  "status"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "cohort_id"
    t.date     "cohort_date"
  end

  create_table "events", :force => true do |t|
    t.integer  "user_id"
    t.integer  "total"
    t.string   "metric"
    t.date     "fulldate"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "events", ["fulldate"], :name => "index_events_on_fulldate"
  add_index "events", ["metric"], :name => "index_events_on_metric"

  create_table "images", :force => true do |t|
    t.integer  "dashboard_id"
    t.string   "purpose"
    t.text     "dataurl",      :limit => 2147483647
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  create_table "isometrics", :force => true do |t|
    t.date     "fulldate"
    t.integer  "movingaverage", :default => 0
    t.datetime "population"
    t.integer  "segment_id"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.datetime "postsNew"
    t.datetime "usersNew"
  end

  create_table "metrics", :force => true do |t|
    t.date     "fulldate"
    t.integer  "dayofweek"
    t.integer  "dayofyear"
    t.integer  "weekofyear"
    t.integer  "monthofyear"
    t.integer  "year"
    t.integer  "movingaverage", :default => 0
    t.integer  "population"
    t.integer  "segment_id"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.integer  "postsNew"
    t.integer  "usersNew"
  end

  add_index "metrics", ["movingaverage"], :name => "index_metrics_on_movingaverage"

  create_table "populations", :force => true do |t|
    t.integer  "demographic_id"
    t.integer  "user_id"
    t.integer  "segment_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "segments", :force => true do |t|
    t.integer  "demographic_id"
    t.string   "name"
    t.integer  "status"
    t.date     "status_date"
    t.integer  "division_id"
    t.integer  "cached_population"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "provider"
    t.string   "uid"
    t.string   "identifier_url"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "users", ["identifier_url"], :name => "index_users_on_identifier_url", :unique => true

end
