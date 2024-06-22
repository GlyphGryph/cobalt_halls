class Grub < ApplicationRecord
  belongs_to :container

  validates :name, presence: true
  validates :description, presence: :true
end
