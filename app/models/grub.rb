class Grub < ApplicationRecord
  belongs_to :container

  validates :name, presence: true
  validates :description, presence: :true

  def key
    @grub = "grub#{self.id}"
  end

  def seen_as
    seen = []
    seen << description
    return seen
  end
end
