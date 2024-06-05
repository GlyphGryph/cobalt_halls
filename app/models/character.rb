class Character < ApplicationRecord
  belongs_to :room

  def move(destination)
    self.room = destination
    self.save!
  end

  def sees
    other_characters = room.characters - [self]
    puts room.description+"\n"+"Characters here: "+ other_characters.map(&:id).join(", ")
  end
end
