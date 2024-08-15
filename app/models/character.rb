class Character < ApplicationRecord
  include Actionable

  belongs_to :room
  belongs_to :tribe, optional: true
  has_and_belongs_to_many :observers, dependent: :destroy
  has_many :commanders, dependent: :destroy
  has_many :accounts, through: :commanders
  belongs_to :hands, :class_name => 'Container', :foreign_key => 'container_id', dependent: :destroy, optional: true

  before_validation :set_description
  before_create :add_hands

  scope :unclaimed, -> { where('id NOT IN (SELECT character_id FROM commanders)') }

  def key
    @key ||= "char#{self.id}"
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
end
