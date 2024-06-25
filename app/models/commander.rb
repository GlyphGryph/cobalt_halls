class Commander < ApplicationRecord
  has_and_belongs_to_many :accounts
  belongs_to :subordinate, class_name: :Character, foreign_key: "character_id"  

  def process(primary, components=[])
    Rails.logger.info("COMMAND ISSUED || PRIMARY COMMAND: #{primary}, ARGUMENTS: #{components}")
    primary = primary.downcase
    match = subordinate.commands[primary]
    if(match.present?)
      if(components.present?)
        subordinate.send(match[:method], components)
      else
        subordinate.send(match[:method])
      end
    else
      subordinate.display("Invalid Command for Character #{subordinate.id}: #{primary} #{components.join(" ")}")
      return false
    end
  end
end
