class AddHungerToCharacters < ActiveRecord::Migration[7.0]
  def change
    add_column :characters, :hunger, :integer, null: false, default: 0
  end
end
