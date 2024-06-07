class AddFacingToCharacter < ActiveRecord::Migration[7.0]
  def change
    add_column :characters, :facing, :integer, default: 1, null: false
  end
end
