class DirectionLogic
  # "direction" or "absolute_direction" refers to absolute direction, 1 through 6, with 1 being "North"
  # "relative_direction" refers to direction relative to a given facing, with 1 being "Forward"
  @direction_name_mappings = {
    1 => "North (1)",
    2 => "Neast (2)",
    3 => "Seast (3)",
    4 => "South (4)",
    5 => "Swest (5)",
    6 => "Nwest (6)"
  }
  @direction_name_to_number_mappings = @direction_name_mappings.invert
  @relative_direction_name_mappings = {
    1 => "Ahead (1)",
    2 => "Ahead Right (2)",
    3 => "Behind Right (3)",
    4 => "Behind (4)",
    5 => "Behind Left (5)",
    6 => "Ahead Left (6)"

  }
  @anterior_mappings = {
    1 => 4,
    2 => 5,
    3 => 6,
    4 => 1,
    5 => 2,
    6 => 3
  }
  
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
    return (facing+relative_direction-2)%6+1
  end

  def self.get_relative_direction_from_absolute_direction(facing, absolute_direction)
    return (absolute_direction-facing)%6+1
  end

  def self.perspective_name(facing, absolute_direction)
    relative_direction = self.get_relative_direction_from_absolute_direction(facing, absolute_direction)
    return get_name_from_relative_direction(relative_direction)
  end
end
