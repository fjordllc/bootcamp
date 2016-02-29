class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :report

  validates :description, presence: true
end
