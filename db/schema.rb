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

ActiveRecord::Schema[8.1].define(version: 2026_03_05_123334) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
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
    t.datetime "created_at", null: false
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

  create_table "booking_seats", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.datetime "created_at", null: false
    t.bigint "seat_id", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id", "seat_id"], name: "index_booking_seats_on_booking_id_and_seat_id", unique: true
    t.index ["booking_id"], name: "index_booking_seats_on_booking_id"
    t.index ["seat_id"], name: "index_booking_seats_on_seat_id"
  end

  create_table "bookings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.string "reference_code", null: false
    t.integer "status", default: 0, null: false
    t.decimal "total_amount", precision: 10, scale: 2, default: "0.0", null: false
    t.integer "total_seats", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["event_id"], name: "index_bookings_on_event_id"
    t.index ["reference_code"], name: "index_bookings_on_reference_code", unique: true
    t.index ["status"], name: "index_bookings_on_status"
    t.index ["user_id", "event_id"], name: "index_bookings_on_user_id_and_event_id"
    t.index ["user_id"], name: "index_bookings_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.integer "capacity", default: 0, null: false
    t.string "category"
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "end_at", null: false
    t.string "image_url"
    t.string "location_note"
    t.bigint "organizer_id", null: false
    t.decimal "price", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "start_at", null: false
    t.integer "status", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "venue_id", null: false
    t.index ["category"], name: "index_events_on_category"
    t.index ["organizer_id"], name: "index_events_on_organizer_id"
    t.index ["start_at"], name: "index_events_on_start_at"
    t.index ["status"], name: "index_events_on_status"
    t.index ["venue_id"], name: "index_events_on_venue_id"
  end

  create_table "reminders", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.datetime "created_at", null: false
    t.datetime "remind_at", null: false
    t.integer "reminder_type", default: 0, null: false
    t.boolean "sent", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_reminders_on_booking_id"
    t.index ["remind_at"], name: "index_reminders_on_remind_at"
    t.index ["sent"], name: "index_reminders_on_sent"
  end

  create_table "seats", force: :cascade do |t|
    t.boolean "available", default: true, null: false
    t.integer "column", null: false
    t.datetime "created_at", null: false
    t.string "label", null: false
    t.integer "row", null: false
    t.integer "seat_type", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "venue_id", null: false
    t.index ["available"], name: "index_seats_on_available"
    t.index ["seat_type"], name: "index_seats_on_seat_type"
    t.index ["venue_id", "row", "column"], name: "index_seats_on_venue_id_and_row_and_column", unique: true
    t.index ["venue_id"], name: "index_seats_on_venue_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "avatar_url"
    t.text "bio"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name", default: "", null: false
    t.string "last_name", default: "", null: false
    t.string "phone"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "venues", force: :cascade do |t|
    t.string "address", null: false
    t.string "city", null: false
    t.integer "columns", default: 10, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "image_url"
    t.string "name", null: false
    t.integer "rows", default: 10, null: false
    t.datetime "updated_at", null: false
    t.index ["city"], name: "index_venues_on_city"
    t.index ["name"], name: "index_venues_on_name"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "booking_seats", "bookings"
  add_foreign_key "booking_seats", "seats"
  add_foreign_key "bookings", "events"
  add_foreign_key "bookings", "users"
  add_foreign_key "events", "users", column: "organizer_id"
  add_foreign_key "events", "venues"
  add_foreign_key "reminders", "bookings"
  add_foreign_key "seats", "venues"
end
