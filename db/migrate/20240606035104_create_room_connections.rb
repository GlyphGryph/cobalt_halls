class CreateRoomConnections < ActiveRecord::Migration[7.0]
  def change
    create_table :room_connections do |t|
      t.integer :start_room_id, null: false
      t.integer :end_room_id, null: false
      t.integer :start_room_direction, null: false
      t.integer :end_room_direction, null: false
      t.text :transition_message, default: "", null: false

      t.timestamps
    end
    add_index :room_connections, :start_room_id
    add_index :room_connections, :end_room_id
  end
end
