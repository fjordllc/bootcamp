class PracticesBook < ApplicationRecord
  belongs_to :practice
  belongs_to :book
  validates :must_read, inclusion: { in: [true, false] }
end
