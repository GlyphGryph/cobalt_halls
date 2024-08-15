class Commander < ApplicationRecord
  include Actionable
  has_and_belongs_to_many :accounts
  belongs_to :subordinate, class_name: :Character, foreign_key: "character_id"  

private
  def actionable_action_ids
    [:command]
  end

  def actionable_children
    [subordinate]
  end
end
