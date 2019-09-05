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

ActiveRecord::Schema.define(version: 20160830151035) do

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace",     limit: 255
    t.text     "body",          limit: 65535
    t.string   "resource_id",   limit: 255,   null: false
    t.string   "resource_type", limit: 255,   null: false
    t.integer  "author_id",     limit: 4
    t.string   "author_type",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "admin_users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "articles", force: :cascade do |t|
    t.string   "title",          limit: 255
    t.text     "body",           limit: 65535
    t.integer  "position",       limit: 4
    t.datetime "trending_until"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "posts_count",    limit: 4,     default: 0, null: false
    t.string   "thumbnail",      limit: 255
    t.string   "slug",           limit: 255
  end

  add_index "articles", ["slug"], name: "index_articles_on_slug", unique: true, using: :btree

  create_table "attachments", force: :cascade do |t|
    t.string  "type_of_attachment", limit: 255
    t.string  "title",              limit: 255
    t.text    "description",        limit: 65535
    t.string  "image",              limit: 255
    t.integer "attachable_id",      limit: 4
    t.string  "attachable_type",    limit: 255
    t.integer "user_id",            limit: 4
    t.integer "admin_user_id",      limit: 4
  end

  create_table "breaking_news", force: :cascade do |t|
    t.text     "title",          limit: 65535
    t.datetime "trending_until"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "chats", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comments", force: :cascade do |t|
    t.integer  "user_id",             limit: 4
    t.integer  "commentable_id",      limit: 4
    t.string   "commentable_type",    limit: 255
    t.text     "body",                limit: 65535
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.integer  "reply_to_comment_id", limit: 4
    t.integer  "likes_count",         limit: 4,     default: 0
    t.boolean  "marked_for_deletion",               default: false
  end

  create_table "companies", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.string   "abbr",           limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "exchange",       limit: 255
    t.integer  "market_cap",     limit: 8
    t.string   "sector",         limit: 255
    t.integer  "position",       limit: 4
    t.datetime "trending_until"
  end

  create_table "favorites", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "post_id",    limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "favorites", ["user_id", "post_id"], name: "index_favorites_on_user_id_and_post_id", unique: true, using: :btree

  create_table "follows", force: :cascade do |t|
    t.integer  "follower_id",   limit: 4
    t.integer  "followee_id",   limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "followee_type", limit: 255
  end

  add_index "follows", ["followee_id"], name: "index_follows_on_followee_id", using: :btree
  add_index "follows", ["follower_id", "followee_id", "followee_type"], name: "by_belonging", unique: true, using: :btree
  add_index "follows", ["follower_id"], name: "index_follows_on_follower_id", using: :btree

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",           limit: 255, null: false
    t.integer  "sluggable_id",   limit: 4,   null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope",          limit: 255
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "likes", force: :cascade do |t|
    t.integer  "user_id",       limit: 4
    t.integer  "likeable_id",   limit: 4
    t.string   "likeable_type", limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "likes", ["likeable_id", "likeable_type"], name: "index_likes_on_likeable_id_and_likeable_type", unique: true, using: :btree
  add_index "likes", ["user_id"], name: "index_likes_on_user_id", using: :btree

  create_table "market_headlines", force: :cascade do |t|
    t.string   "title",          limit: 255
    t.integer  "position",       limit: 4
    t.datetime "trending_until"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "mentions", force: :cascade do |t|
    t.integer  "user_id",          limit: 4,   null: false
    t.integer  "mentionable_id",   limit: 4,   null: false
    t.string   "mentionable_type", limit: 255, null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "messages", force: :cascade do |t|
    t.string   "body",           limit: 255
    t.integer  "chat_id",        limit: 4
    t.integer  "participant_id", limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "messages", ["chat_id"], name: "index_messages_on_chat_id", using: :btree

  create_table "news_items", force: :cascade do |t|
    t.text     "url",                  limit: 65535
    t.string   "title",                limit: 255
    t.string   "agency",               limit: 255
    t.datetime "published_at"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.text     "summary",              limit: 65535
    t.text     "stemmed_keywords",     limit: 65535
    t.integer  "news_subject_id",      limit: 4
    t.integer  "position",             limit: 4
    t.string   "news_thumbnail",       limit: 255
    t.datetime "trending_until"
    t.text     "not_stemmed_keywords", limit: 65535
    t.integer  "news_item_type",       limit: 4
    t.integer  "company_id",           limit: 4
    t.boolean  "locally_hosted",                     default: false, null: false
    t.integer  "posts_count",          limit: 4,     default: 0,     null: false
    t.string   "slug",                 limit: 255
  end

  add_index "news_items", ["company_id"], name: "index_news_items_on_company_id", using: :btree
  add_index "news_items", ["slug"], name: "index_news_items_on_slug", unique: true, using: :btree

  create_table "news_subjects", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notifications", force: :cascade do |t|
    t.integer  "notifiable_id",     limit: 4
    t.string   "notifiable_type",   limit: 255
    t.integer  "user_id",           limit: 4,                   null: false
    t.boolean  "seen",                          default: false
    t.string   "notification_type", limit: 255, default: "",    null: false
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
  end

  create_table "participants", force: :cascade do |t|
    t.integer  "user_id",              limit: 4
    t.integer  "chat_id",              limit: 4
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "last_seen_message_id", limit: 4
  end

  add_index "participants", ["chat_id"], name: "index_participants_on_chat_id", using: :btree
  add_index "participants", ["user_id"], name: "index_participants_on_user_id", using: :btree

  create_table "posts", force: :cascade do |t|
    t.text     "content",             limit: 65535
    t.integer  "user_id",             limit: 4
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.string   "picture",             limit: 255
    t.boolean  "friends_only",                      default: false
    t.integer  "comments_count",      limit: 4,     default: 0
    t.integer  "likes_count",         limit: 4,     default: 0
    t.boolean  "marked_for_deletion",               default: false
    t.integer  "article_id",          limit: 4
    t.string   "article_type",        limit: 255
  end

  add_index "posts", ["user_id", "created_at"], name: "index_posts_on_user_id_and_created_at", using: :btree
  add_index "posts", ["user_id"], name: "index_posts_on_user_id", using: :btree

  create_table "relationships", force: :cascade do |t|
    t.integer  "follower_id",     limit: 4
    t.integer  "followable_id",   limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "followable_type", limit: 255
  end

  add_index "relationships", ["followable_id"], name: "index_relationships_on_followable_id", using: :btree
  add_index "relationships", ["follower_id", "followable_id", "followable_type"], name: "by_belonging", unique: true, using: :btree
  add_index "relationships", ["follower_id"], name: "index_relationships_on_follower_id", using: :btree

  create_table "shortened_urls", force: :cascade do |t|
    t.integer  "owner_id",   limit: 4
    t.string   "owner_type", limit: 20
    t.string   "url",        limit: 255,             null: false
    t.string   "unique_key", limit: 10,              null: false
    t.integer  "use_count",  limit: 4,   default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "expires_at"
  end

  add_index "shortened_urls", ["owner_id", "owner_type"], name: "index_shortened_urls_on_owner_id_and_owner_type", using: :btree
  add_index "shortened_urls", ["unique_key"], name: "index_shortened_urls_on_unique_key", unique: true, using: :btree
  add_index "shortened_urls", ["url"], name: "index_shortened_urls_on_url", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "post_id",    limit: 4
    t.integer  "tag_id",     limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "taggings", ["post_id"], name: "index_taggings_on_post_id", using: :btree
  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.integer  "tag_type",       limit: 4,               null: false
    t.integer  "taggings_count", limit: 4,   default: 0, null: false
    t.string   "word",           limit: 255
    t.string   "description",    limit: 255
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "position",       limit: 4
    t.datetime "trending_until"
    t.datetime "mute_until"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                       limit: 255,   default: "",    null: false
    t.string   "encrypted_password",          limit: 255,   default: "",    null: false
    t.string   "reset_password_token",        limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",               limit: 4,     default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",          limit: 255
    t.string   "last_sign_in_ip",             limit: 255
    t.string   "confirmation_token",          limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "notification_subscription",                 default: false
    t.string   "username",                    limit: 255
    t.string   "name",                        limit: 255
    t.string   "occupation",                  limit: 255
    t.string   "education",                   limit: 255
    t.string   "experience",                  limit: 255
    t.float    "latitude",                    limit: 24
    t.float    "longitude",                   limit: 24
    t.string   "location",                    limit: 255
    t.string   "primary_investment_strategy", limit: 255
    t.string   "average_investment_period",   limit: 255
    t.text     "remember_token",              limit: 65535
    t.string   "avatar",                      limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
