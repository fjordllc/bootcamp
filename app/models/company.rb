class Company < ActiveRecord::Base
  validates :name, presence: true
end
