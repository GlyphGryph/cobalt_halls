class Commander < ApplicationRecord
  has_and_belongs_to_many :accounts
  belongs_to :subordinate, class_name: :Character, foreign_key: "character_id"  

  def process(primary, components=[])
    subordinate.reload
    subordinate.try(:room).try(:reload)
    Rails.logger.info("COMMAND ISSUED || PRIMARY COMMAND: #{primary}, ARGUMENTS: #{components}")
    primary = primary.downcase
    action = subordinate.find_command(primary)
    if(action.present?)
      if(components.present?)
        subordinate.send(action.method, components)
      else
        subordinate.send(action.method)
      end
    else
      subordinate.display("Invalid Command for Character #{subordinate.id}: #{primary} #{components.join(" ")}")
      return false
    end
  end
end
