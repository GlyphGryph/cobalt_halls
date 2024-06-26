class AddDescriptionsToRoomConnection < ActiveRecord::Migration[7.0]
  def change
    add_column :room_connections, :description, :string
    remove_column :room_connections, :transition_message, :text
  end
end
