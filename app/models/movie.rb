# frozen_string_literal: true

class Movie < ApplicationRecord
  include Searchable
  include WithAvatar
  include Taggable
  include Reactionable
  include Commentable
  include Watchable
  include Bookmarkable

  belongs_to :user
  belongs_to :practice, optional: true
  belongs_to :last_updated_user, class_name: 'User', optional: true
  has_one_attached :thumbnail
  has_one_attached :movie_data

  validates :user, presence: true
  validates :title, presence: true
  validates :description, presence: true

  scope :wip, -> { where(wip: true) }
end
