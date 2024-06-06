class Character < ApplicationRecord
  belongs_to :room
  has_and_belongs_to_many :observers

  def other_characters
    return room.characters - [self]
  end

  def teleport(destination)
    other_characters.each{|oc| oc.display("#{name} disppears in a flash of light.")}
    self.room = destination
    self.save!
    display(sees("With a flash of light, you find yourself in a new place..."))
    other_characters.each{|oc| oc.display("#{name} pops into existence.")}
  end

  def move(direction)
    target_connection = room.start_room_connections.find_by(start_room_direction: direction)
    if(target_connection.present?)
      destination = target_connection.end_room
      other_characters.each{|oc| oc.display("#{name} leaves the room.")}
      self.room = destination
      self.save!
      display(sees("You enter the room..."))
      other_characters.each{|oc| oc.display("#{name} enters the room.")}
    else
      display("You can't move in that direction")
    end
  end

  def name
    id.to_s
  end

  def sees(lead=nil)
    seen = []
    seen << (lead || "You look around the room...")
    seen << room.description
    if(other_characters.present?)
      seen << "Characters here: "+ other_characters.map(&:id).join(", ")
    end
    seen << "Visible exists: "+room.exits.join(",")
    return seen
  end

  def look
    display(sees)
  end

  def display(messages)
    messages = Array(messages)
    observers.each do |observer|
      observer.display(messages, self)
    end
  end
end
