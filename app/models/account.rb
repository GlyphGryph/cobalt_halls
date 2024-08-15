class Account < ApplicationRecord
  include Actionable

  has_and_belongs_to_many :commanders
  belongs_to :observer, optional: true
  validates :name, presence: true, allow_blank: false, uniqueness: true

  after_create :create_observer

  def characters
    characters = observer.characters
    return characters
  end

  # TODO: Possible race condition, what if multiple people claim at same time?
  # Probably worth putting in a mutex with checks and stuff, even if unlikely
  def claim(character)
    if(commanders.where(subordinate: character).present?)
      display("Account already commanding #{character.key}")
    else
      display("Obtaining command of #{character.key}...")
      self.commanders << Commander.create!(subordinate: character)
    end
    if(observer.characters.include?(character))
      display("Account already observing #{character.key}")
    else
      display("Observing #{character.key}...")
      observer.characters << character
      observer.save!
    end
    display("Claimed #{character.key}! You now have your own kobold.")
  end

  def abandon_all
    commanders.destroy_all
    observer.characters.clear
  end

private
  def create_observer
    self.observer = Observer.create!
    self.save!
  end

  def actionable_action_ids
    [:tribes, :claim]
  end

  def actionable_children
    commanders
  end

  def tribes_action(components)
    messages = []
    messages << "Tribes:"
    Tribe.all.each do |tribe|
      members = tribe.characters
      unclaimed_members = members.unclaimed
      messages << "#{tribe.name} (#{unclaimed_members.count}/#{members.count} unclaimed)"
      unclaimed_members.each do |character|
        messages << "- #{character.key}"
      end
      messages << ""
    end
    display(messages)
  end

  def claim_action(components)
    if(characters.present?)
      display("You have already claimed a kobold")
      return
    end
    key = components.first
    if(key.empty?)
      display("You must provide a character id for the kobold you wish to claim.")
      return
    end
    character = Character.all.find{|character| character.key==key}
    if(character.present?)
      display("Attempting to claim #{character.key}...")
      if(character.claimable?)
        claim(character)
      else
        display("Character is not available to be claimed.")
      end
    else
      display("Could not find #{character.key}")
    end
  end

  def channel_id
    @channel_id = "channel-#{self.id}"
  end
end
