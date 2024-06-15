class CreateCommanders < ActiveRecord::Migration[7.0]
  def change
    create_table :commanders do |t|
      t.string :identifier
      t.references :character, null: false, foreign_key: true

      t.timestamps
    end
  end
end
