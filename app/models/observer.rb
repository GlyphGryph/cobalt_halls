class Observer < ApplicationRecord
  has_one :account
  has_and_belongs_to_many :characters

  def channel_id
    @channel_id = "observer-#{self.id}"
  end

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
    out = "=== Message from: #{lead} ===\n"
    messages.each do |message|
      out += message+"\n"
    end
    out + "---\n"
    print out
    ActionCable.server.broadcast(channel_id, {action: "display", messages: messages})
  end
end
