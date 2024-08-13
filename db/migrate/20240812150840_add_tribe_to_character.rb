class AddTribeToCharacter < ActiveRecord::Migration[7.0]
  def change
    add_reference :characters, :tribe, foreign_key: true
  end
end
