class CreateCharacters < ActiveRecord::Migration[7.0]
  def change
    create_table :characters do |t|
      t.references :room, null: false, foreign_key: true

      t.timestamps
    end
  end
end
