class Room < ApplicationRecord
  has_many :characters
  has_many :start_room_connections, class_name: "RoomConnection", foreign_key: 'start_room_id', dependent: :destroy
  has_many :end_room_connections, class_name: "RoomConnection", foreign_key: "end_room_id", dependent: :destroy
  belongs_to :container, optional: true
  has_many :grubs, through: :container
  validates :description, presence: true
  validates :name, presence: true

  before_create :add_container

  def exits
    portals = []
    start_room_connections.each do |connection|
      portals << OpenStruct.new({direction: connection.start_room_direction, description: connection.description})
    end
    return portals
  end

  def connect(direction, target_room, description)
    errors = []
    op_direction = DirectionLogic.get_anterior(direction)
    start_connection = RoomConnection.create(
      start_room: self,
      start_room_direction: direction,
      end_room: target_room,
      end_room_direction: op_direction,
      description: description
    )
    errors << start_connection.errors
    end_connection = RoomConnection.create(
      start_room: target_room,
      start_room_direction: op_direction,
      end_room: self,
      end_room_direction: direction
    )
  end

  def find_contents(arguments=[])
    # find players
    found = self.characters.detect{|character| arguments.first == character.key}
    if(!found)
     found =  self.container.grubs.detect{|grub| arguments.first == grub.key}
    end

    return found
  end

private
  def add_container
    self.container = Container.create!
  end
end
