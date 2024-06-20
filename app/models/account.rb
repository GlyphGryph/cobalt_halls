class Account < ApplicationRecord
  has_and_belongs_to_many :commanders
  belongs_to :observer, optional: true
  validates :name, presence: true, allow_blank: false, uniqueness: true

  after_create :create_character
  
  def characters
    characters = observer.characters
    return characters
  end

private
  def create_character
    character = Character.create!(room: Room.first)
    self.observer = Observer.create!(characters: [character])
    self.commanders << Commander.create(subordinate: character)
    self.save!
  end
end
