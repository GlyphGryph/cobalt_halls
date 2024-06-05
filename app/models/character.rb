class Character < ApplicationRecord
  belongs_to :room
  has_and_belongs_to_many :observers

  def other_characters
    return room.characters - [self]
  end

  def move(destination)
    other_characters.each{|oc| oc.display("#{name} has left the room.")}
    self.room = destination
    self.save!
    display(sees("You enter the room..."))
    other_characters.each{|oc| oc.display("#{name} has entered the room.")}
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
