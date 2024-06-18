class AddObserverToAccount < ActiveRecord::Migration[7.0]
  def change
    add_reference :accounts, :observer, foreign_key: true
  end
end
