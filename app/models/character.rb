class Character < ApplicationRecord
  belongs_to :room
  has_and_belongs_to_many :observers, dependent: :destroy
  has_many :commanders, dependent: :destroy
  belongs_to :hands, :class_name => 'Container', :foreign_key => 'container_id', dependent: :destroy, optional: true


  before_create :add_hands

  def self.commands
    return @command_list if defined?(@command_list)
    @command_list = {}
    @command_list["look"] = {
      description: "Shows contents of room by just typing 'look', or examine an object by typing 'look [object]'. Use 'look self' to examine your current state.",
      method: :look
    }
    @command_list["move"] = {
      description: "Move forward, or in a given direction, 'move [direction]'. Moves character through an exit to a new area. Valid directions are 'forward' (or 'f'), 'right' (or 'r'), 'left' (or 'l'), and 'back' (or 'b')",
      method: :move
    }
    @command_list["turn"] = {
      description: "Change facing.",
      method: :turn
    }
    @command_list["get"] = {
      description: "Move an item to your inventory.",
      method: :get
    }
    @command_list["drop"] = {
      description: "Move an item out of your inventory",
      method: :drop
    }
    @command_list["help"] = {
      description: "Lists valid commands for character",
      method: :help
    }
    return @command_list
  end

  def commands
    Character.commands
  end

  def key
    @key ||= "char#{self.id}"
  end

  def help(arguments=[])
    return @help_response if @help_response
    @help_response = []
    @help_response << "Valid commands"
    commands.values.each do |command|
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
      relative_direction = 'f'
    else
      relative_direction = arguments.first
    end

    relative_direction = DirectionLogic.get_direction_from_string(relative_direction)

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
    room.reload
    seen = []
    seen << (lead || "You look around the room...")
    seen << room.description
    if(room.grubs.present?)
      seen << "Items here: "+room.grubs.map{|grub| "#{grub.name} (#{grub.key})"}.join(", ")
    end
    if(other_characters.present?)
      seen << "Characters here: "+ other_characters.map(&:key).join(", ")
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
    # error handling
    if(arguments.empty?)
      # default direction is forward
      change_direction = 'b'
    else
      change_direction = arguments.first
    end

    change_direction = DirectionLogic.get_direction_from_string(change_direction)

    if(!DirectionLogic.valid_directions.include?(change_direction))
      display("That's not a valid direction")
      return
    end


    if(0 == change_direction)
      display("You are already facing forward.")
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

  def look(arguments=[])
    if(arguments.empty? || arguments.first == "room")
      display(sees)
      return
    end

    messages = []
    if("self" == arguments.first)
      messages << "You look at yourself."
      messages.concat(self.seen_as)
    elsif(found = self.find_contents(arguments))
      # Check self contents (inventory) and display seen_as for any matches
      messages.concat(found.seen_as)
    elsif(found = room.find_contents(arguments))
      # Check room contents (characters, exits, items) and display seen_as for any matches
      messages.concat(found.seen_as)
    else
      messages << "Nothing found that matches '#{arguments}'"
    end

    display(messages)
  end

  def find_contents(arguments=[])
    self.hands.grubs.detect{|grub| arguments.first == grub.key}
  end

  def seen_as
    self.reload
    seen = []
    seen << "Name: #{self.id}"
    seen << "Position: #{room.name}"
    seen << "Facing: #{self.facing}"
    seen << "Has the following items: #{self.hands.grubs.map{|grub| "#{grub.name} (#{grub.key})"}.join(", ")}"
    return seen
  end

  def get(arguments=[])
    found = self.room.find_contents(arguments)
    if(found)
      found.container = self.hands
      found.save!
      display("You get up the #{arguments.first}.")
      other_characters.each{|oc| oc.display("#{name} gets the #{arguments.first}.")}
    else
      display("You couldn't find any #{arguments.first} to get.")
    end
  end

  def drop(arguments=[])
    found = self.find_contents(arguments)
    if(found)
      found.container = self.room.container
      found.save!
      display("You drop the #{arguments.first}.")
      other_characters.each{|oc| oc.display("#{name} drops the #{arguments.first}.")}
    else
      display("You couldn't find any #{arguments.first} to get.")
    end
  end

  def display(messages)
    messages = Array(messages)
    Rails.logger.info "Displaying message: #{messages}"
    observers.each do |observer|
      observer.display(messages, self)
    end
  end

private
  def add_hands
    self.hands = Container.create!
  end
end
