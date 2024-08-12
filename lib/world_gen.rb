class WorldGen
  def self.generate_world
    cleanup_world
    the_hole = Room.create!({
      name: "The Hole", 
      description: "This is the bottom of a large, deep hole. Dim sunlight filters down from far above. The walls are rough, undecorated stone, and the floor is muddy and rank smelling. Against the wall is a small stone staircase leading to a simple wooden door."
    })
    hallway_start = Room.create!({
      name: "one side of a long hallway",
      description: "This is one side of a long hallway, lit by iron oil lamps. The walls are wood, and a red carpet runs the length of the hallway. There are doors against each wall, and a path further down the hallway."
    })
    the_hole.connect(0, hallway_start, "a simple wooden door")
    hallway_start.connect(2, the_hole, "a simple wooden door")

    first_closet = Room.create!({
      name: "an empty closet",
      description: "An empty closet."
    })
    second_closet = Room.create!({
      name: "an empty closet",
      description: "An empty closet."
    })
    hallway_start.connect(1, first_closet, "a black door")
    hallway_start.connect(3, second_closet, "a black door")
    first_closet.connect(3, hallway_start, "a door")
    second_closet.connect(1, hallway_start, "a door")

    hallway_mid = Room.create!({
      name: "middle of a long hallway",
      description: "This is the middle of a long hallway, lit by iron oil lamps. The walls are wood, and a red carpet runs the length of the hallway. There are doors against both walls, and more hallway in either direction."
    })
    hallway_start.connect(0, hallway_mid, "down the hallway")
    hallway_mid.connect(2, hallway_start, "down the hallway")
    third_closet = Room.create!({
      name: "an empty closet",
      description: "An empty closet."
    })
    fourth_closet = Room.create!({
      name: "an empty closet",
      description: "An empty closet."
    })
    hallway_start.connect(1, third_closet, "a black door")
    hallway_start.connect(3, fourth_closet, "a black door")
    third_closet.connect(3, hallway_start, "a door")
    fourth_closet.connect(1, hallway_start, "a door")

    hallway_end = Room.create!({
      name: "one side of a long hallway",
      description: "This is one side of a long hallway, lit by iron oil lamps. The walls are wood, and a red carpet runs the length of the hallway. There are doors against each wall, and a path further down the hallway."
    })
    hallway_mid.connect(0, hallway_end, "down the hallway")
    hallway_end.connect(2, hallway_mid, "down the hallway")
    fifth_closet = Room.create!({
      name: "an empty closet",
      description: "An empty closet."
    })
    sixth_closet = Room.create!({
      name: "an empty closet",
      description: "An empty closet."
    })
    hallway_start.connect(1, fifth_closet, "a black door")
    hallway_start.connect(3, sixth_closet, "a black door")
    fifth_closet.connect(3, hallway_start, "a door")
    sixth_closet.connect(1, hallway_start, "a door")

    bedroom = Room.create!({
      name: "a bedroom",
      description: "This room has a bed against either wall."
    })
    hallway_end.connect(0, bedroom, "a wrought-iron door")
    bedroom.connect(2, hallway_end, "a wrought-iron door")

    # Characters
    5.times do
      Character.create!(room: Room.first)
    end
  end

  def self.cleanup_world
    Grub.destroy_all
    Character.destroy_all
    Room.destroy_all
    Container.destroy_all
  end
end
