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

ActiveRecord::Schema.define(version: 20161024062425) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "activities", force: :cascade do |t|
    t.integer  "trackable_id"
    t.string   "trackable_type"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "key"
    t.text     "parameters"
    t.string   "aasm_state",     default: "unread"
    t.integer  "recipient_id"
    t.string   "recipient_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
  add_index "activities", ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
  add_index "activities", ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree

  create_table "admin_users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "attachments", force: :cascade do |t|
    t.string   "name"
    t.integer  "attachable_id"
    t.string   "attachable_type"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "attachments", ["attachable_id"], name: "index_attachments_on_attachable_id", using: :btree

  create_table "carts", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "aasm_state"
  end

  add_index "carts", ["product_id"], name: "index_carts_on_product_id", using: :btree
  add_index "carts", ["user_id"], name: "index_carts_on_user_id", using: :btree

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "image"
  end

  create_table "checkout_items", force: :cascade do |t|
    t.integer  "product_id"
    t.integer  "checkout_id"
    t.decimal  "price"
    t.string   "rent_time"
    t.decimal  "total_price"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.decimal  "deposit"
    t.datetime "start_time",    default: '2018-12-06 02:16:07'
    t.datetime "end_time"
    t.datetime "reminder_time"
    t.string   "item_type"
    t.string   "aasm_state"
  end

  add_index "checkout_items", ["checkout_id"], name: "index_checkout_items_on_checkout_id", using: :btree
  add_index "checkout_items", ["product_id"], name: "index_checkout_items_on_product_id", using: :btree

  create_table "checkouts", force: :cascade do |t|
    t.integer  "payment_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "user_id"
    t.string   "aasm_state"
    t.decimal  "total_paid"
    t.string   "pay_key"
    t.string   "checkout_type"
    t.string   "transaction_id"
    t.string   "payment_type"
    t.string   "pay_status"
  end

  add_index "checkouts", ["payment_id"], name: "index_checkouts_on_payment_id", using: :btree
  add_index "checkouts", ["user_id"], name: "index_checkouts_on_user_id", using: :btree

  create_table "favourites", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "favouritable_id"
    t.string   "favouritable_type"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "favourites", ["favouritable_id"], name: "index_favourites_on_favouritable_id", using: :btree
  add_index "favourites", ["user_id"], name: "index_favourites_on_user_id", using: :btree

  create_table "google_ads_locations", force: :cascade do |t|
    t.string   "name"
    t.integer  "width"
    t.string   "location"
    t.integer  "number"
    t.string   "status"
    t.integer  "sort_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "homes", force: :cascade do |t|
    t.string   "title"
    t.string   "app_description"
    t.string   "google_play_url"
    t.string   "features_one_title"
    t.string   "features_one_description"
    t.string   "features_two_title"
    t.string   "features_two_description"
    t.string   "features_three_title"
    t.string   "features_three_description"
    t.string   "features_four_title"
    t.string   "features_four_description"
    t.string   "application_information_title"
    t.string   "application_information_description"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "junkyard_products", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.string   "location"
    t.text     "special_condition"
    t.string   "size"
    t.string   "latitude"
    t.string   "longitude"
    t.string   "aasm_state"
    t.integer  "category_id"
    t.integer  "user_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "favourites_count",  default: 0
  end

  add_index "junkyard_products", ["category_id"], name: "index_junkyard_products_on_category_id", using: :btree
  add_index "junkyard_products", ["user_id"], name: "index_junkyard_products_on_user_id", using: :btree

  create_table "messages", force: :cascade do |t|
    t.string   "topic"
    t.text     "body"
    t.integer  "received_messageable_id"
    t.string   "received_messageable_type"
    t.integer  "sent_messageable_id"
    t.string   "sent_messageable_type"
    t.boolean  "opened",                     default: false
    t.boolean  "recipient_delete",           default: false
    t.boolean  "sender_delete",              default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ancestry"
    t.boolean  "recipient_permanent_delete", default: false
    t.boolean  "sender_permanent_delete",    default: false
    t.integer  "documentable_id"
    t.string   "documentable_type"
  end

  add_index "messages", ["ancestry"], name: "index_messages_on_ancestry", using: :btree
  add_index "messages", ["documentable_id"], name: "index_messages_on_documentable_id", using: :btree
  add_index "messages", ["sent_messageable_id", "received_messageable_id"], name: "acts_as_messageable_ids", using: :btree

  create_table "mobile_platforms", force: :cascade do |t|
    t.string   "device_id"
    t.string   "device_model"
    t.integer  "user_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "mobile_platforms", ["user_id"], name: "index_mobile_platforms_on_user_id", using: :btree

  create_table "pages", force: :cascade do |t|
    t.string   "heading"
    t.string   "slug"
    t.string   "url"
    t.string   "meta_title"
    t.text     "meta_description"
    t.text     "short_intro"
    t.text     "content"
    t.string   "banner"
    t.string   "menu_title"
    t.string   "menu_position"
    t.integer  "menu_sort_order"
    t.boolean  "active"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "pages", ["slug"], name: "index_pages_on_slug", unique: true, using: :btree

  create_table "payments", force: :cascade do |t|
    t.string   "paypal_email"
    t.integer  "user_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "aasm_state"
  end

  add_index "payments", ["user_id"], name: "index_payments_on_user_id", using: :btree

  create_table "products", force: :cascade do |t|
    t.string   "name"
    t.integer  "category_id"
    t.text     "description"
    t.string   "location"
    t.text     "special_condition"
    t.decimal  "deposit"
    t.integer  "user_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "size"
    t.string   "latitude"
    t.string   "longitude"
    t.string   "aasm_state"
    t.decimal  "one_hour",          default: 0.0
    t.decimal  "four_hours",        default: 0.0
    t.decimal  "one_day",           default: 0.0
    t.decimal  "one_week",          default: 0.0
    t.integer  "favourites_count",  default: 0
    t.string   "rent_status"
  end

  add_index "products", ["category_id"], name: "index_products_on_category_id", using: :btree
  add_index "products", ["user_id"], name: "index_products_on_user_id", using: :btree

  create_table "rent_histories", force: :cascade do |t|
    t.integer  "renter_id"
    t.integer  "lender_id"
    t.string   "rent_time"
    t.string   "aasm_state"
    t.integer  "product_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "rent_type"
    t.decimal  "price"
    t.integer  "checkout_id"
    t.integer  "checkout_item_id"
  end

  add_index "rent_histories", ["checkout_id"], name: "index_rent_histories_on_checkout_id", using: :btree
  add_index "rent_histories", ["checkout_item_id"], name: "index_rent_histories_on_checkout_item_id", using: :btree
  add_index "rent_histories", ["product_id"], name: "index_rent_histories_on_product_id", using: :btree

  create_table "reviews", force: :cascade do |t|
    t.integer  "quality",                  default: 0
    t.integer  "price",                    default: 0
    t.integer  "deposit",                  default: 0
    t.integer  "service",                  default: 0
    t.integer  "tool_safely",              default: 0
    t.integer  "return_on_time",           default: 0
    t.integer  "return_in_good_and_clean", default: 0
    t.integer  "overall_rating",           default: 0
    t.text     "comment"
    t.integer  "user_id"
    t.integer  "target_id"
    t.string   "target_type"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.integer  "product_id"
    t.string   "aasm_state"
  end

  add_index "reviews", ["product_id"], name: "index_reviews_on_product_id", using: :btree
  add_index "reviews", ["target_id"], name: "index_reviews_on_target_id", using: :btree
  add_index "reviews", ["user_id"], name: "index_reviews_on_user_id", using: :btree

  create_table "system_settings", force: :cascade do |t|
    t.string   "name"
    t.string   "logo"
    t.string   "email_sender"
    t.integer  "listing_per_page"
    t.boolean  "maintenance_mode"
    t.text     "maintenance_message"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "transfer_requests", force: :cascade do |t|
    t.decimal  "requested_amount"
    t.string   "aasm_state"
    t.integer  "user_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "transfer_requests", ["user_id"], name: "index_transfer_requests_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "first_name"
    t.string   "last_name"
    t.text     "address"
    t.string   "latitude"
    t.string   "longitude"
    t.string   "authentication_token"
    t.string   "phone_number"
    t.boolean  "hide_address",           default: false
    t.decimal  "balance",                default: 0.0
    t.boolean  "is_blocked",             default: false
    t.text     "description"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "votes", force: :cascade do |t|
    t.integer  "votable_id"
    t.string   "votable_type"
    t.integer  "voter_id"
    t.string   "voter_type"
    t.boolean  "vote_flag"
    t.string   "vote_scope"
    t.integer  "vote_weight"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["votable_id", "votable_type", "vote_scope"], name: "index_votes_on_votable_id_and_votable_type_and_vote_scope", using: :btree
  add_index "votes", ["voter_id", "voter_type", "vote_scope"], name: "index_votes_on_voter_id_and_voter_type_and_vote_scope", using: :btree

  add_foreign_key "junkyard_products", "categories"
  add_foreign_key "junkyard_products", "users"
  add_foreign_key "mobile_platforms", "users"
  add_foreign_key "rent_histories", "checkout_items"
  add_foreign_key "rent_histories", "checkouts"
  add_foreign_key "rent_histories", "products"
  add_foreign_key "transfer_requests", "users"
end
