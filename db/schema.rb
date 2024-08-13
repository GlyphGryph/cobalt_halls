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

ActiveRecord::Schema[7.0].define(version: 2024_08_12_150840) do
  create_table "accounts", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "observer_id"
    t.index ["name"], name: "index_accounts_on_name"
    t.index ["observer_id"], name: "index_accounts_on_observer_id"
  end

  create_table "accounts_commanders", id: false, charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "commander_id", null: false
    t.index ["account_id", "commander_id"], name: "index_accounts_commanders_on_account_id_and_commander_id"
    t.index ["commander_id", "account_id"], name: "index_accounts_commanders_on_commander_id_and_account_id"
  end

  create_table "characters", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.bigint "room_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "facing", default: 1, null: false
    t.bigint "container_id", null: false
    t.text "description", null: false
    t.bigint "tribe_id"
    t.index ["container_id"], name: "index_characters_on_container_id"
    t.index ["room_id"], name: "index_characters_on_room_id"
    t.index ["tribe_id"], name: "index_characters_on_tribe_id"
  end

  create_table "characters_observers", id: false, charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.bigint "observer_id", null: false
    t.bigint "character_id", null: false
    t.index ["character_id", "observer_id"], name: "index_characters_observers_on_character_id_and_observer_id"
    t.index ["observer_id", "character_id"], name: "index_characters_observers_on_observer_id_and_character_id"
  end

  create_table "commanders", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "identifier"
    t.bigint "character_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_commanders_on_character_id"
  end

  create_table "containers", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "grubs", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "container_id", null: false
    t.index ["container_id"], name: "index_grubs_on_container_id"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description"
    t.index ["end_room_id"], name: "index_room_connections_on_end_room_id"
    t.index ["start_room_id"], name: "index_room_connections_on_start_room_id"
  end

  create_table "rooms", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.bigint "container_id", null: false
    t.index ["container_id"], name: "index_rooms_on_container_id"
  end

  create_table "tribes", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "accounts", "observers"
  add_foreign_key "characters", "containers"
  add_foreign_key "characters", "rooms"
  add_foreign_key "characters", "tribes"
  add_foreign_key "commanders", "characters"
  add_foreign_key "grubs", "containers"
  add_foreign_key "rooms", "containers"
end
