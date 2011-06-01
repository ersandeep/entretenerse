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

ActiveRecord::Schema.define(:version => 20110225092401) do

  create_table "accounts", :force => true do |t|
    t.datetime "date",        :null => false
    t.float    "amount",      :null => false
    t.integer  "campaign_id", :null => false
    t.integer  "sponsor_id",  :null => false
  end

  add_index "accounts", ["campaign_id"], :name => "account_campaign_fk"
  add_index "accounts", ["sponsor_id"], :name => "account_sponsor_kf"

  create_table "attributes", :force => true do |t|
    t.string  "name",              :limit => 50,                   :null => false
    t.integer "parent_id"
    t.string  "value",             :limit => 50,                   :null => false
    t.string  "icon",              :limit => 50
    t.integer "order"
    t.integer "count"
    t.integer "events_count"
    t.integer "occurrences_count"
    t.boolean "on_home_page",                    :default => true, :null => false
  end

  add_index "attributes", ["parent_id"], :name => "attribute_attribute_fk"
  add_index "attributes", ["value"], :name => "IDX_attributes_value"

  create_table "calendars", :force => true do |t|
    t.datetime "date",                     :null => false
    t.integer  "dayOfWeek",                :null => false
    t.integer  "month",                    :null => false
    t.integer  "day",                      :null => false
    t.string   "status",    :limit => 1,   :null => false
    t.string   "reason",    :limit => 400
  end

  add_index "calendars", ["date"], :name => "calendars_date", :unique => true
  add_index "calendars", ["dayOfWeek"], :name => "IDX_calendar_dayOfWeek"

  create_table "campaign_type", :force => true do |t|
    t.string "name", :limit => 50, :null => false
    t.string "type", :limit => 1,  :null => false
  end

  create_table "campaign_types", :force => true do |t|
    t.string "name",  :limit => 50, :null => false
    t.string "ctype", :limit => 1,  :null => false
  end

  create_table "campaigns", :force => true do |t|
    t.datetime "start"
    t.datetime "end"
    t.integer  "campaign_type_id",              :default => 0, :null => false
    t.integer  "sponsor_id",                    :default => 0, :null => false
    t.string   "status",           :limit => 1,                :null => false
  end

  add_index "campaigns", ["campaign_type_id"], :name => "campaign_campaign_type_fk"
  add_index "campaigns", ["sponsor_id"], :name => "campaign_campaign_type"

  create_table "categories", :force => true do |t|
    t.string  "name",         :limit => 100
    t.integer "attribute_id"
  end

  add_index "categories", ["attribute_id"], :name => "event_type_attribute"

  create_table "comments", :id => false, :force => true do |t|
    t.integer   "id",                              :null => false
    t.string    "title",            :limit => 45
    t.string    "comment",          :limit => 200
    t.timestamp "created_at",                      :null => false
    t.integer   "user_id",                         :null => false
    t.string    "commentable_type", :limit => 45,  :null => false
    t.integer   "commentable_id",                  :null => false
  end

  add_index "comments", ["user_id"], :name => "fk_comments_user"

  create_table "crawlers", :force => true do |t|
    t.string   "name",                          :null => false
    t.string   "home_page",                     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.boolean  "running",    :default => false
  end

  create_table "crawlers_log", :force => true do |t|
    t.integer  "crawler_id",                 :null => false
    t.string   "status"
    t.string   "url",        :limit => 2048, :null => false
    t.text     "pull_data"
    t.text     "push_data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_campaign", :id => false, :force => true do |t|
    t.integer "campaign_id", :null => false
    t.integer "event_id",    :null => false
  end

  add_index "event_campaign", ["campaign_id"], :name => "event_campaign_campaign_fk"

  create_table "event_place", :id => false, :force => true do |t|
    t.integer "place_id", :null => false
    t.integer "event_id", :null => false
  end

  add_index "event_place", ["event_id"], :name => "event_place_event_fk"

  create_table "event_tag", :id => false, :force => true do |t|
    t.integer "event_id", :null => false
    t.integer "tag_id",   :null => false
  end

  add_index "event_tag", ["event_id"], :name => "event_tag_event_fk"

  create_table "event_target", :id => false, :force => true do |t|
    t.integer "event_id",  :null => false
    t.integer "target_id", :null => false
    t.integer "order"
  end

  add_index "event_target", ["target_id"], :name => "event_target_target_fk"

  create_table "events", :force => true do |t|
    t.string   "title",       :limit => 128,                         :null => false
    t.text     "description",                                        :null => false
    t.text     "text",        :limit => 2147483647
    t.string   "thumbnail",   :limit => 200
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
    t.integer  "sponsor_id",                                         :null => false
    t.float    "price"
    t.string   "image_url",   :limit => 200
    t.string   "web",         :limit => 200
    t.integer  "duration"
    t.integer  "category_id"
    t.float    "rating",                            :default => 0.0, :null => false
    t.integer  "rated_count",                       :default => 0,   :null => false
  end

  add_index "events", ["category_id"], :name => "IDX_events_category"
  add_index "events", ["sponsor_id"], :name => "event_sponsor_fk"
  add_index "events", ["title", "description", "text"], :name => "title"

  create_table "events_attributes", :id => false, :force => true do |t|
    t.integer "event_id",     :null => false
    t.integer "attribute_id", :null => false
  end

  add_index "events_attributes", ["event_id"], :name => "event_attribute_event_fk"

  create_table "events_pepe", :force => true do |t|
    t.text "text"
  end

  add_index "events_pepe", ["text"], :name => "newindex"

  create_table "occurrence_searches", :primary_key => "occurrence_id", :force => true do |t|
    t.text "search_text", :limit => 2147483647
  end

  add_index "occurrence_searches", ["search_text"], :name => "search_text"

  create_table "occurrences", :force => true do |t|
    t.datetime "date"
    t.integer  "dayOfWeek"
    t.datetime "from"
    t.datetime "to"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "place_id",   :null => false
    t.integer  "event_id",   :null => false
    t.time     "hour"
  end

  add_index "occurrences", ["date"], :name => "index_occurrences_on_date"
  add_index "occurrences", ["event_id"], :name => "ocurrence_event_fk"
  add_index "occurrences", ["place_id"], :name => "ocurrence_place_fk"

  create_table "occurrences_attributes", :id => false, :force => true do |t|
    t.integer "occurrence_id", :null => false
    t.integer "attribute_id",  :null => false
  end

  add_index "occurrences_attributes", ["occurrence_id"], :name => "occurrences_attributes_occurrence_fk"

  create_table "performances", :id => false, :force => true do |t|
    t.integer "event_id",                   :null => false
    t.integer "performer_id",               :null => false
    t.string  "rol",          :limit => 45, :null => false
    t.integer "order"
  end

  add_index "performances", ["performer_id"], :name => "event_performer_performer_fk"

  create_table "performers", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",       :limit => 50, :default => " ", :null => false
  end

  create_table "places", :force => true do |t|
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.string   "name",       :limit => 50,  :null => false
    t.string   "address",    :limit => 50
    t.string   "town",       :limit => 50
    t.string   "state",      :limit => 50
    t.string   "country",    :limit => 50
    t.string   "phone",      :limit => 128
  end

  add_index "places", ["name"], :name => "IDX_places_name"
  add_index "places", ["name"], :name => "name"

  create_table "preferences", :force => true do |t|
    t.integer "rank",         :null => false
    t.integer "user_id",      :null => false
    t.integer "attribute_id", :null => false
  end

  add_index "preferences", ["attribute_id", "user_id"], :name => "preference_user_attribute", :unique => true
  add_index "preferences", ["attribute_id"], :name => "preference_attribute_fk"
  add_index "preferences", ["user_id"], :name => "preference_user_fk"

  create_table "promotions", :force => true do |t|
    t.integer "campaign_id", :null => false
    t.integer "event_id",    :null => false
  end

  add_index "promotions", ["campaign_id"], :name => "promotion_campaign_fk"
  add_index "promotions", ["event_id"], :name => "promotion_event_fk"

  create_table "sponsors", :force => true do |t|
    t.string   "name",       :limit => 50,  :null => false
    t.float    "credit",                    :null => false
    t.string   "telephone",  :limit => 50
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.integer  "user_id",                   :null => false
    t.string   "url",        :limit => 100
    t.string   "email",      :limit => 100
  end

  add_index "sponsors", ["user_id"], :name => "sponsor_user_fk"

  create_table "tags", :force => true do |t|
    t.string "name", :limit => 45, :null => false
  end

  create_table "targets", :force => true do |t|
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
    t.string   "name",       :limit => 50, :null => false
  end

  create_table "users", :force => true do |t|
    t.string  "name",      :limit => 50,                    :null => false
    t.string  "password",  :limit => 50
    t.string  "firstName", :limit => 50
    t.string  "email",     :limit => 50
    t.string  "clickpass", :limit => 50,                    :null => false
    t.string  "lastName",  :limit => 50
    t.boolean "admin",                   :default => false, :null => false
  end

end
