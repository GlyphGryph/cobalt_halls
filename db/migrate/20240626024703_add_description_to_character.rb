class AddDescriptionToCharacter < ActiveRecord::Migration[7.0]
  def change
    add_column :characters, :description, :text, null: false
  end
end
