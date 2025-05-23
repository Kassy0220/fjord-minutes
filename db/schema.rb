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

ActiveRecord::Schema[7.2].define(version: 2025_04_23_062941) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider", null: false
    t.string "uid", null: false
    t.string "name"
    t.string "avatar_url"
    t.index ["email"], name: "index_admins_on_email", unique: true
  end

  create_table "attendances", force: :cascade do |t|
    t.boolean "attended", null: false
    t.integer "session"
    t.string "absence_reason"
    t.text "progress_report"
    t.bigint "member_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "meeting_id", null: false
    t.index ["meeting_id"], name: "index_attendances_on_meeting_id"
    t.index ["member_id", "meeting_id"], name: "index_attendances_on_member_id_and_meeting_id", unique: true
    t.index ["member_id"], name: "index_attendances_on_member_id"
  end

  create_table "courses", force: :cascade do |t|
    t.string "name"
    t.integer "meeting_week"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "kind"
  end

  create_table "hibernations", force: :cascade do |t|
    t.date "finished_at"
    t.bigint "member_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_hibernations_on_member_id"
  end

  create_table "meetings", force: :cascade do |t|
    t.date "date"
    t.date "next_date"
    t.datetime "notified_at"
    t.bigint "course_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_meetings_on_course_id"
    t.index ["date", "course_id"], name: "index_meetings_on_date_and_course_id", unique: true
  end

  create_table "members", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "uid"
    t.string "name"
    t.string "avatar_url"
    t.bigint "course_id", null: false
    t.index ["course_id"], name: "index_members_on_course_id"
    t.index ["email"], name: "index_members_on_email", unique: true
  end

  create_table "minutes", force: :cascade do |t|
    t.string "release_branch", default: ""
    t.string "release_note", default: ""
    t.text "other", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "exported", default: false
    t.bigint "meeting_id", null: false
    t.index ["meeting_id"], name: "index_minutes_on_meeting_id"
  end

  create_table "topics", force: :cascade do |t|
    t.string "content", null: false
    t.bigint "minute_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "topicable_id"
    t.string "topicable_type"
    t.index ["minute_id"], name: "index_topics_on_minute_id"
    t.index ["topicable_id", "topicable_type"], name: "index_topics_on_topicable_id_and_topicable_type"
  end

  add_foreign_key "attendances", "meetings"
  add_foreign_key "attendances", "members"
  add_foreign_key "hibernations", "members"
  add_foreign_key "meetings", "courses"
  add_foreign_key "members", "courses"
  add_foreign_key "minutes", "meetings"
  add_foreign_key "topics", "minutes"
end
