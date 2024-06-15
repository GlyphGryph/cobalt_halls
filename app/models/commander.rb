class Commander < ApplicationRecord
  belongs_to :subordinate, class_name: :Character, foreign_key: "character_id"  

  def process(*components)
    primary = components.first.downcase
    puts "PRIMARY IS #{primary}"
    match = subordinate.command_list[primary]
    puts "COMMAND LIST IS:"
    p subordinate.command_list
    if(match.present?)
      subordinate.send(match[:method])
    else
      subordinate.display("Invalid Command Character #{subordinate.id}: #{components.join(", ")}")
    end
  end
end
