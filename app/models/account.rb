class Account < ApplicationRecord
  include Actionable

  has_and_belongs_to_many :commanders
  belongs_to :observer, optional: true
  validates :name, presence: true, allow_blank: false, uniqueness: true

  def characters
    characters = observer.characters
    return characters
  end

private
  def actionable_action_ids
    @actionable_action_ids ||= []
  end

  def actionable_children
    []
  end
end
