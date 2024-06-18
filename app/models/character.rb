class Character < ApplicationRecord
  belongs_to :room
  has_and_belongs_to_many :observers
  has_many :commanders, dependent: :destroy
 
  def self.command_list
    @@command_list ||= {
      "look" => {
        id: "look",
        description: "Shows contents of room",
        method: :look
      },
      "move" => {
        id: "move",
        description: "Requires a direction, 'move [direction]'. Moves character through an exit to a new area.",
        method: :move
      },
      "help" => {
        id: "help",
        description: "Lists valid commands for character",
        method: :help
      }
    }
  end

  def command_list
    Character.command_list
  end
    

  def help
    return @help_response if @help_response
    @help_response = []
    @help_response << "Valid commands"
    @command_list.values.each do |command|
      @help_response << "#{command[:id]}: #{command[:description]}"
    end
    display(@help_response)
  end

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
  
  def absolute_move(direction)
    target_connection = room.start_room_connections.find_by(start_room_direction: direction)
    direction_name = DirectionLogic.get_name_from_absolute_direction(direction)
    if(target_connection.present?)
      destination = target_connection.end_room
      other_characters.each{|oc| oc.display("#{name} leaves the room.")}
      self.room = destination
      self.facing = DirectionLogic.get_anterior(target_connection.end_room_direction)
      self.save!
      display(sees("You enter the room..."))
      other_characters.each{|oc| oc.display("#{name} enters the room.")}
    else
      display("You can't move in that direction (#{direction_name})")
    end
  end

  def move(relative_direction=nil, *trash)
    Rails.logger.info "TRYING TO MOVE #{relative_direction}"
    if(relative_direction && Room::valid_directions.include?(relative_direction.to_i))
      relative_direction = relative_direction.to_i
      absolute_direction = DirectionLogic.get_absolute_direction_from_relative_direction(self.facing, relative_direction)
      absolute_move(absolute_direction)
    else
      display("You must supply a valid direction.")
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
    exits_list = room.exits.map do |absolute_direction|
      "#{DirectionLogic.perspective_name(self.facing, absolute_direction)} [#{DirectionLogic.get_name_from_absolute_direction(absolute_direction)}]"
    end
    seen << "You are facing #{self.facing}"
    seen << ("Visible exits: "+exits_list.join(", "))
    return seen
  end

  def turn_left
    self.facing = (self.facing - 2)%6 + 1
    self.save!
  end

  def turn_right
    self.facing = (self.facing)%6 + 1
    self.save!
  end

  def turn(relative_direction)
    self.facing=relative_direction;
    self.save!
  end

  def look
    display(sees)
  end

  def look_self
    seen = []
    seen << "Name: #{self.id}"
    seen << "Position: #{room.name}"
    seen << "Facing: #{self.facing}"
    display(seen)
  end

  def display(messages)
    messages = Array(messages)
    observers.each do |observer|
      observer.display(messages, self)
    end
  end
end
