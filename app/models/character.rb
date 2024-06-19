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
      "turn" => {
        id: "turn",
        description: "Change facing.",
        method: :turn
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
    

  def help(arguments=[])
    return @help_response if @help_response
    @help_response = []
    @help_response << "Valid commands"
    command_list.values.each do |command|
      @help_response << "#{command[:id]}: #{command[:description]}"
    end
    display(@help_response)
  end

  def other_characters
    return room.characters - [self]
  end

  def teleport(arguments=[])
    # error handling
    if(arguments.empty?)
      display("A destination must be provided.")
      return
    end
    destination_id = arguments.first
    room = Room.find_by(id: destination_id)
    if(room.empty?)
      display("The destination is invalid.")
      return
    end

    # action
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

  def move(arguments=[])
    # error handling
    if(arguments.empty?)
      # default direction is forward
      relative_direction = 0
    else
      relative_direction = arguments.first.to_i
    end

    if(!DirectionLogic.valid_directions.include?(relative_direction))
      display("That's not a valid direction")
      return
    end

    absolute_direction = DirectionLogic.get_absolute_direction_from_relative_direction(
      self.facing, relative_direction
    )
    absolute_move(absolute_direction)
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
    seen << "You are facing #{self.facing}"
    seen << visible_exits
    return seen
  end

  def visible_exits
    exits_list = room.exits.map do |absolute_direction|
      "#{DirectionLogic.perspective_name(self.facing, absolute_direction)} [#{DirectionLogic.get_name_from_absolute_direction(absolute_direction)}]"
    end
    "Visible exits: "+exits_list.join(", ")
  end

  def turn(arguments=[])
    if(arguments.empty?)
      change_direction = 2
    else
      change_direction = arguments.first.to_i
    end
    if(0 == change_direction)
      display("You are already facing forward.")
      return
    end
    if(!DirectionLogic.valid_directions.include?(change_direction))
      display("#{change_direction} is not a valid direction.")
      return
    end
    self.facing=DirectionLogic.get_rotation(self.facing, change_direction)
    self.save!
    messages = []
    if(1==change_direction)
      messages << "You turned right."
    elsif(2==change_direction)
      messages << "You turned around."
    elsif(3==change_direction)
      messages << "You turned left."
    end
    messages << visible_exits
    display(messages)
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
