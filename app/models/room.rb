class Room < ApplicationRecord
  has_many :characters
  has_many :start_room_connections, class_name: "RoomConnection", foreign_key: 'start_room_id', dependent: :destroy
  has_many :end_room_connections, class_name: "RoomConnection", foreign_key: "end_room_id", dependent: :destroy
  belongs_to :container, optional: true

  before_create :add_container

  def exits
    exits = []
    start_room_connections.each do |connection|
      exits << connection.start_room_direction
    end
    return exits
  end

  def connect(direction, target_room)
    errors = []
    op_direction = DirectionLogic.get_anterior(direction)
    start_connection = RoomConnection.create(
      start_room: self,
      start_room_direction: direction,
      end_room: target_room,
      end_room_direction: op_direction
    )
    errors << start_connection.errors
    end_connection = RoomConnection.create(
      start_room: target_room,
      start_room_direction: op_direction,
      end_room: self,
      end_room_direction: direction
    )
  end

  def name
    self.id
  end

private
  def add_container
    self.container = Container.create!
  end
end
