class AddContainerToGrub < ActiveRecord::Migration[7.0]
  def change
    add_reference :grubs, :container, null: false, foreign_key: true
  end
end
