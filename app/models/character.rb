class Character < ApplicationRecord
  belongs_to :room

  def move(destination)
    self.room = destination
    self.save!
  end

  def sees
    room.description
  end
end
