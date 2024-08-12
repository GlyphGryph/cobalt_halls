class RemoveNullConstrainersForContainers < ActiveRecord::Migration[7.0]
  def change
    def up
      change_column_null :grubs, :container_id, true
      change_column_null :rooms, :container_id, true
      change_column_null :characters, :container_id, true
    end

    def down
      change_column_null :grubs, :container_id, false
      change_column_null :rooms, :container_id, false
      change_column_null :characters, :container_id, false
    end
  end
end
