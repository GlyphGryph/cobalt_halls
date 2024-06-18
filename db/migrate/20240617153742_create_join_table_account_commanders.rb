class CreateJoinTableAccountCommanders < ActiveRecord::Migration[7.0]
  def change
    create_join_table :accounts, :commanders do |t|
      t.index [:account_id, :commander_id]
      t.index [:commander_id, :account_id]
    end
  end
end
