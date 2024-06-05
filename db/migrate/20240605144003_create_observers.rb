class CreateObservers < ActiveRecord::Migration[7.0]
  def change
    create_table :observers do |t|
      t.timestamps
    end

    create_join_table :observers, :characters do |t|
      t.index [:observer_id, :character_id]
      t.index [:character_id, :observer_id]
    end
  end
end
