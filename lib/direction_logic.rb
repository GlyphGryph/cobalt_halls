class DirectionLogic
  # "direction" or "absolute_direction" refers to absolute direction, 1 through 6, with 1 being "North"
  # "relative_direction" refers to direction relative to a given facing, with 1 being "Forward"
  @direction_name_mappings = {
    0 => "North",
    1 => "East",
    2 => "South",
    3 => "West"
  }
  @direction_name_to_number_mappings = @direction_name_mappings.invert
  @relative_direction_name_mappings = {
    0 => "Forward",
    1 => "Right",
    2 => "Back",
    3 => "Left"
  }
  @anterior_mappings = {
    0 => 2,
    1 => 3,
    2 => 0,
    3 => 1
  }

  @string_to_direction_mappings = {
    'f' => 0,
    'forward' => 0,
    'r' => 1,
    'right' => 1,
    'b' => 2,
    'back' => 2,
    'l' => 3,
    'left' => 3
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

  def self.get_direction_from_string(input)
    return @string_to_direction_mappings[input.downcase]
  end

  def self.get_name_from_relative_direction(relative_direction)
    return @relative_direction_name_mappings[relative_direction]
  end

  def self.get_absolute_direction_from_relative_direction(facing, relative_direction)
    return (facing+relative_direction)%4
  end

  def self.get_relative_direction_from_absolute_direction(facing, absolute_direction)
    return (absolute_direction-facing)%4
  end

  def self.perspective_name(facing, absolute_direction)
    relative_direction = self.get_relative_direction_from_absolute_direction(facing, absolute_direction)
    return get_name_from_relative_direction(relative_direction)
  end

  def self.get_rotation(current_direction, change)
    return (current_direction+change)%4
  end
end
