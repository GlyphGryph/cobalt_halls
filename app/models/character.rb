class Character < ApplicationRecord
  belongs_to :room

  def move(destination)
    self.room = destination
    self.save!
    sees
  end

  def sees(lead=nil)
    seen = lead || "You look around the room...\n"
    other_characters = room.characters - [self]
    seen+= room.description+"\n"
    if(other_characters.present?)
      seen+= "Characters here: "+ other_characters.map(&:id).join(", ")+"\n"
    end
    print seen
  end
end
