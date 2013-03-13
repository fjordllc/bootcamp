class Practice < ActiveRecord::Base
  validates :title, presence: true
  validates :description, presence: true
end
