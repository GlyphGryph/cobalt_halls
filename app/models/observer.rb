class Observer < ApplicationRecord
  has_and_belongs_to_many :characters

  def observe(character)
    if(characters.include?(character))
      display("You are already observing #{character.name}")
    else
      self.characters << character
      display("You are now observing #{character.name}")
    end
  end

  def ignore(character)
    if(characters.include?(character)
      self.characters.delete(character)
      display("You are now ignoring #{character.name}"))
    else
      display("You are now ignoring #{character.name}")
    end
  end

  def display(messages, source=nil)
    messages = Array(messages)
    lead = "WORLD"
    lead = source.name if(source.present?)
    print "=== Message from: #{lead} ===\n"
    messages.each do |message|
      print message+"\n"
    end
    print "---\n"
  end
end
