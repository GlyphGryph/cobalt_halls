class Character < ApplicationRecord
  include Actionable

  belongs_to :room
  belongs_to :tribe, optional: true
  has_and_belongs_to_many :observers, dependent: :destroy
  has_many :commanders, dependent: :destroy
  has_many :accounts, through: :commanders
  belongs_to :hands, :class_name => 'Container', :foreign_key => 'container_id', dependent: :destroy, optional: true
  # hunger - hunger can have a value from 10 to 80

  before_validation :set_description
  before_create :add_hands

  scope :claimed, -> { where('id IN (SELECT character_id FROM commanders)') }
  scope :unclaimed, -> { where('id NOT IN (SELECT character_id FROM commanders)') }

  def key
    @key ||= "char#{self.id}"
  end
  
  def hunger_description
    case hunger
    when 0
      "not hungry"
    when 1
      "hungry"
    when 2
      "very hungry"
    when 3
      "ravenous"
    when 4
      "starving"
    end
  end

  def famish(amount=1)
    self.hunger += amount
  end
  
  def feed(amount=100)
    self.hunger = Math.max(self.hunger-1, 0)
  end

  def other_characters
    return room.characters - [self]
  end

  def name
    description || "an unknown creature"
  end

  def find_contents(arguments=[])
    self.hands.grubs.detect{|grub| arguments.first == grub.key}
  end

  def seen_as
    seen = []
    seen << "This is a #{self.description}"
    seen << "Name: #{self.id}"
    seen << "Position: #{room.name}"
    seen << "Facing: #{self.facing}"
    seen << "Has the following items: #{self.hands.grubs.map{|grub| "#{grub.name} (#{grub.key})"}.join(", ")}"
    seen << "Is #{hunger_description}"
    return seen
  end

  def claimable?
    !self.accounts.present?
  end

private
  def add_hands
    self.hands = Container.create!
  end
  
  def set_description
    self.description ||= "a kobold"
  end

  def actionable_action_ids
    [:help, :look, :turn, :move, :get, :drop, :describe, :say, :tribe]
  end

  def tribe_action(components)
    messages = []
    if(tribe.blank?)
      messages << "You are not a member of a tribe."
    else
      messages << "Tribe: #{tribe.name}"
      messages << "Total kobolds: #{tribe.characters.count}"
      messages << "Total souls: #{tribe.characters.claimed.count}"
    end
    display(messages)
  end
end
