module Actionable
  def self.commands
    @all_commands ||= [
      Action.new(:look),
      Action.new(:help),
      Action.new(:move, keys:['move', 'go']),
      Action.new(:teleport),
      Action.new(:turn, keys:['turn', 't']),
      Action.new(:get),
      Action.new(:drop),
      Action.new(:describe),
      Action.new(:say)
    ]
  end

  def self.commands_by_alias
    @all_commands_by_alias ||= Actionable.commands.inject({}) do |result, action|
      action.keys.each do |key|
        result[key] = action
      end
      result
    end
  end

  def self.find_command(key)
    Actionable.commands_by_alias[key]
  end

  def find_command(key)
    Actionable.find_command(key)
  end

  def set_actionable_commands(list)
    @actionable_commands = list
  end
  
  def actionable_commands
    @actionable_commands ||= [:help, :look, :turn, :move, :get, :drop, :describe, :say]
  end

  def valid_commands
    Actionable::commands.select{|command| actionable_commands.include?(command.id)}
  end

  # DEFAULT COMMAND PROCESSING
  def help_action
    return @help_response if @help_response
    @help_response = []
    @help_response << "Valid commands"
    valid_commands.each do |action|
      @help_response << "#{action.id}: #{action.description}"
    end
    display(@help_response)
  end

  def teleport_action(arguments=[])
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

  def move_action(arguments=[])
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

  def sees(lead=nil)
    seen = []
    seen << (lead || "You look around the room...")
    seen << room.description
    if(room.grubs.present?)
      seen << "Items here: "+room.grubs.map{|grub| "#{grub.name} (#{grub.key})"}.join(", ")
    end
    if(other_characters.present?)
      seen << "Characters here: "+ other_characters.map{|character| "#{character.name} (#{character.key})"}.join(", ")
    end
    seen.concat(visible_exits)
    return seen
  end

  def visible_exits
    messages = ["Visible exits: "]
    exits_list = room.exits.map do |portal|
      messages << "#{portal.description} to the #{DirectionLogic.perspective_name(self.facing, portal.direction)}"
    end
    messages
  end

  def turn_action(arguments=[])
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
    messages.concat(visible_exits)
    display(messages)
  end

  def look_action(arguments=[])
    if(arguments.empty? || arguments.first == "room")
      display(sees)
      return
    end

    messages = []
    if("self" == arguments.first)
      messages << "You look at yourself."
      messages << "This creature is #{self.description}"
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

  def get_action(arguments=[])
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

  def drop_action(arguments=[])
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

  def describe_action(arguments=[])
    self.description = arguments.join(" ")
    self.save!
    display(["Your new description is...",self.description])
  end

  def say_action(arguments = [])
    if(arguments.empty?)
      display("You said nothing.")
      other_characters.each{|oc| oc.display("#{name.capitalize} says nothing.")}
    else
      display(%{You say "#{arguments.join(" ")}"})
      other_characters.each{|oc| oc.display(%{#{oc.name.capitalize} says "#{arguments.join(" ")}"})}
    end
  end
end
