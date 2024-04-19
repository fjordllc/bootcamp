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
  has_one_attached :thumbnail
  has_one_attached :movie_data

  validates :user, presence: true, length: { maximum: 255 }
  validates :title, presence: true
  validates :description, presence: true
end
