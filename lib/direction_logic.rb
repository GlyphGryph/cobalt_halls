class DirectionLogic
  @name_mappings = {
    1 => "North",
    2 => "Neast",
    3 => "Seast",
    4 => "South",
    5 => "Swest",
    6 => "Nwest"
  }
  @name_to_number_mappings = @name_mappings.invert
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

  def self.get_name(direction)
    return @name_mappings[direction]
  end

  def self.get_number(name)
    return @name_to_number_mappings[name]
  end
end
