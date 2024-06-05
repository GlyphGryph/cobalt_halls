class Character < ApplicationRecord
  belongs_to :room
  has_and_belongs_to_many :observers

  def move(destination)
    self.room = destination
    self.save!
    display(sees("You enter the room...\n"))
  end

  def name
    id.to_s
  end

  def sees(lead=nil)
    seen = lead || "You look around the room...\n"
    other_characters = room.characters - [self]
    seen+= room.description+"\n"
    if(other_characters.present?)
      seen+= "Characters here: "+ other_characters.map(&:id).join(", ")+"\n"
    end
    return seen
  end

  def look
    display(sees)
  end

  def display(message)
    observers.each do |observer|
      observer.display(message, self)
    end
  end
end
