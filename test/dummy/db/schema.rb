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

ActiveRecord::Schema.define(:version => 20130902084029) do

  create_table "heart_annotations", :force => true do |t|
    t.date     "fulldate"
    t.string   "note"
    t.integer  "dashboard_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "heart_configurations", :force => true do |t|
    t.string   "auth"
    t.string   "username"
    t.string   "password"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "heart_dashboards", :force => true do |t|
    t.string   "title"
    t.text     "dashboard"
    t.text     "description"
    t.date     "date_from"
    t.integer  "status"
    t.string   "supplement"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "heart_images", :force => true do |t|
    t.integer  "dashboard_id"
    t.string   "purpose"
    t.text     "dataurl",      :limit => 2147483647
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  create_table "heart_isometrics", :force => true do |t|
    t.date     "fulldate"
    t.integer  "movingaverage", :default => 0
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.datetime "postsNew"
    t.datetime "usersNew"
  end

  create_table "heart_metrics", :force => true do |t|
    t.date     "fulldate"
    t.integer  "dayofweek"
    t.integer  "dayofyear"
    t.integer  "weekofyear"
    t.integer  "monthofyear"
    t.integer  "year"
    t.integer  "movingaverage", :default => 0
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.integer  "postsNew"
    t.integer  "usersNew"
  end

  add_index "heart_metrics", ["movingaverage"], :name => "index_heart_metrics_on_movingaverage"

end
