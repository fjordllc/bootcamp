class Comment < ActiveRecord::Base
  include PublicActivity::Model
  tracked

  belongs_to :user
  belongs_to :report

  validates :description, presence: true
end
