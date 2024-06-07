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

ActiveRecord::Schema[7.0].define(version: 2024_06_06_190246) do
  create_table "characters", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.bigint "room_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "facing", default: 1, null: false
    t.index ["room_id"], name: "index_characters_on_room_id"
  end

  create_table "characters_observers", id: false, charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.bigint "observer_id", null: false
    t.bigint "character_id", null: false
    t.index ["character_id", "observer_id"], name: "index_characters_observers_on_character_id_and_observer_id"
    t.index ["observer_id", "character_id"], name: "index_characters_observers_on_observer_id_and_character_id"
  end

  create_table "observers", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "room_connections", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.integer "start_room_id", null: false
    t.integer "end_room_id", null: false
    t.integer "start_room_direction", null: false
    t.integer "end_room_direction", null: false
    t.text "transition_message", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["end_room_id"], name: "index_room_connections_on_end_room_id"
    t.index ["start_room_id"], name: "index_room_connections_on_start_room_id"
  end

  create_table "rooms", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "characters", "rooms"
end
