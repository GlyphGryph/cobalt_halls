class DirectionLogic
  # "direction" or "absolute_direction" refers to absolute direction, 1 through 6, with 1 being "North"
  # "relative_direction" refers to direction relative to a given facing, with 1 being "Forward"
  @direction_name_mappings = {
    0 => "North (0)",
    1 => "East (1)",
    2 => "South (2)",
    3 => "West (3)"
  }
  @direction_name_to_number_mappings = @direction_name_mappings.invert
  @relative_direction_name_mappings = {
    0 => "Ahead (0)",
    1 => "Right (1)",
    2 => "Behind (2)",
    3 => "Left (3)"
  }
  @anterior_mappings = {
    0 => 2,
    1 => 3,
    2 => 0,
    3 => 1
  }

  @valid_directions = [0,1,2,3]
  class << self
    attr_reader :valid_directions
  end
  
  def self.get_anterior(direction)
    return @anterior_mappings[direction]
  end

  def self.get_name_from_absolute_direction(direction)
    return @direction_name_mappings[direction]
  end

  def self.get_direction_from_name(name)
    return @direction_name_to_number_mappings[name]
  end

  def self.get_name_from_relative_direction(relative_direction)
    return @relative_direction_name_mappings[relative_direction]
  end

  def self.get_absolute_direction_from_relative_direction(facing, relative_direction)
    return (facing+relative_direction-2)%4+1
  end

  def self.get_relative_direction_from_absolute_direction(facing, absolute_direction)
    return (absolute_direction-facing)%4+1
  end

  def self.perspective_name(facing, absolute_direction)
    relative_direction = self.get_relative_direction_from_absolute_direction(facing, absolute_direction)
    return get_name_from_relative_direction(relative_direction)
  end

  def self.get_rotation(current_direction, change)
    return (current_direction+change)%4+1
  end
end
