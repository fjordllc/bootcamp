class Category < ActiveRecord::Base
  has_many :practices
  validates :name, presence: true
  validates :slug, presence: true
end
