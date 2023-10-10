class Quiz < ApplicationRecord
  has_many :statements, dependent: :destroy

  accepts_nested_attributes_for :statements, allow_destroy: true
end
