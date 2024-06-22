class Container < ApplicationRecord
  has_one :room
  has_one :character
  has_many :grubs, dependent: :destroy
end
