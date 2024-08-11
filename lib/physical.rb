module Physical
  # Gets the room this object is in
  def get_room
  end

  # Gets all objects that are in inventories associated with this object
  def get_contents
  end
  
  # Move this object through a connection off its room into another room
  def move_through(connection)
  end
  
  # Move this object directly to another room or inventory without traveling through intervening space
  def teleport_to(room_or_inventory)
  end 

  # Move this objects to an inventory from a valid source
  def move_into(inventory)
  end
  
  # The Various description methods for physical objects, first and third person
  def descriptions
  end
end
