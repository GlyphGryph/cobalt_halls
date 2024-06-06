class RoomConnection < ApplicationRecord
  # Note that room connections are unidirectional
  # They should thus usually be created in pairs
  belongs_to :start_room, class_name: "Room"
  belongs_to :end_room, class_name: "Room"

  validates_uniqueness_of :start_room_id, :scope => [:start_room_direction]
  validates_uniqueness_of :end_room_id, :scope => [:end_room_direction]

  # Later Valid room directions:
  # 7,8 : Up, Down
  # 9..14: UpNorth, UpNeast, UpSeast, UpSouth, UpSwest, UpNwest
  # 15..20: DownNorth, DownNeast, DownSeast, DownSouth, DownSwest, DownNwest
end
